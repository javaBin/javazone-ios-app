import XCTest
import SwiftData
@testable import JavaZone

/// Exercises the decode + persist logic of SessionService against an in-memory store.
/// The network call itself is not covered — the JSON shape and the favourite-preservation
/// rule are the parts that break.
@MainActor
final class SessionServiceTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        container = try ModelContainer(
            for: Session.self, SessionBody.self, Speaker.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        context = nil
        container = nil
        try super.tearDownWithError()
    }

    // MARK: - Decoding

    func testDecodesSessionFields() throws {
        let list = try decode(Self.sampleJson)
        XCTAssertEqual(list.sessions.count, 3)

        let session = try XCTUnwrap(list.sessions.first { $0.sessionId == "s1" })
        XCTAssertEqual(session.title, "Kotlin in anger")
        XCTAssertEqual(session.room, "Room 1")
        XCTAssertEqual(session.format, "presentation")
        XCTAssertEqual(session.audience, "Everyone")
        XCTAssertEqual(session.videoId, "12345")
        XCTAssertEqual(session.speakers?.count, 2)
    }

    func testDecodesZuluDates() throws {
        let list = try decode(Self.sampleJson)
        let session = try XCTUnwrap(list.sessions.first { $0.sessionId == "s1" })
        let expected = ISO8601DateFormatter().date(from: "2025-09-03T09:00:00Z")
        XCTAssertEqual(session.startUtc, expected)
    }

    func testSessionWithoutTimesDecodesWithNilDates() throws {
        let list = try decode(Self.sampleJson)
        let session = try XCTUnwrap(list.sessions.first { $0.sessionId == "s3" })
        XCTAssertNil(session.startUtc)
        XCTAssertNil(session.endUtc)
    }

    // MARK: - Persisting

    func testSessionsWithoutIdAreSkipped() throws {
        try persist(decode(Self.sampleJson))
        let stored = try context.fetch(FetchDescriptor<Session>())
        // The fixture has 3 entries; one carries no sessionId.
        XCTAssertEqual(stored.count, 2)
        XCTAssertNil(stored.first { $0.sessionId == nil })
    }

    func testSpeakerNamesAreSortedAndJoined() throws {
        try persist(decode(Self.sampleJson))
        let session = try XCTUnwrap(fetchSession("s1"))
        XCTAssertEqual(session.speakerNames, "Ada Lovelace, Grace Hopper")
    }

    func testTwitterHandlePrefixIsStripped() throws {
        try persist(decode(Self.sampleJson))
        let body = try XCTUnwrap(fetchBody("s1"))
        let ada = try XCTUnwrap(body.speakerArray.first { $0.wrappedName == "Ada Lovelace" })
        XCTAssertEqual(ada.twitter, "ada")
        XCTAssertEqual(ada.wrappedTwitterUrl, URL(string: "https://twitter.com/ada"))
    }

    func testEmptyTwitterHandleBecomesNil() throws {
        try persist(decode(Self.sampleJson))
        let body = try XCTUnwrap(fetchBody("s1"))
        let grace = try XCTUnwrap(body.speakerArray.first { $0.wrappedName == "Grace Hopper" })
        XCTAssertNil(grace.twitter)
        XCTAssertNil(grace.wrappedTwitterUrl)
    }

    func testBodyIsLinkedToItsSpeakers() throws {
        try persist(decode(Self.sampleJson))
        let body = try XCTUnwrap(fetchBody("s1"))
        XCTAssertEqual(body.speakerArray.count, 2)
        XCTAssertEqual(body.wrappedAbstract, "All about Kotlin")
    }

    // MARK: - Favourites survive a refresh

    func testFavouritesArePreservedAcrossRefresh() throws {
        try persist(decode(Self.sampleJson))
        let session = try XCTUnwrap(fetchSession("s1"))
        session.favourite = true
        try context.save()

        try persist(decode(Self.sampleJson))

        let refreshed = try XCTUnwrap(fetchSession("s1"))
        XCTAssertTrue(refreshed.favourite)
        XCTAssertFalse(try XCTUnwrap(fetchSession("s3")).favourite)
    }

    func testRefreshDoesNotDuplicateRows() throws {
        try persist(decode(Self.sampleJson))
        try persist(decode(Self.sampleJson))

        XCTAssertEqual(try context.fetch(FetchDescriptor<Session>()).count, 2)
        XCTAssertEqual(try context.fetch(FetchDescriptor<SessionBody>()).count, 2)
        XCTAssertEqual(try context.fetch(FetchDescriptor<Speaker>()).count, 2)
    }

    func testFavouriteForDroppedSessionIsNotResurrected() throws {
        try persist(decode(Self.sampleJson))
        let session = try XCTUnwrap(fetchSession("s1"))
        session.favourite = true
        try context.save()

        // Second refresh where s1 is no longer in the programme.
        try persist(decode(Self.shrunkJson))

        XCTAssertNil(fetchSession("s1"))
        XCTAssertEqual(try context.fetch(FetchDescriptor<Session>()).count, 1)
    }

    // MARK: - Helpers

    private func decode(_ json: String) throws -> RemoteSessionList {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(RemoteSessionList.self, from: Data(json.utf8))
    }

    /// Mirrors the store-writing half of SessionService.refresh, which is otherwise only
    /// reachable behind a network call.
    private func persist(_ list: RemoteSessionList) throws {
        let favouriteDescriptor = FetchDescriptor<Session>(predicate: #Predicate { $0.favourite == true })
        let favourites = Set(((try? context.fetch(favouriteDescriptor)) ?? []).compactMap(\.sessionId))

        try? context.delete(model: Speaker.self)
        try? context.delete(model: SessionBody.self)
        try? context.delete(model: Session.self)

        for remote in list.sessions {
            guard let id = remote.sessionId else { continue }
            let body = SessionBody(
                sessionId: id,
                abstract: remote.abstract,
                audience: remote.audience,
                workshopPrerequisites: remote.workshopPrerequisites
            )
            context.insert(body)
            var names: [String] = []
            for remoteSpeaker in remote.speakers ?? [] {
                guard let name = remoteSpeaker.name else { continue }
                let twitter: String? = {
                    guard let handle = remoteSpeaker.twitter, !handle.isEmpty else { return nil }
                    return handle.deletePrefix("@")
                }()
                context.insert(Speaker(
                    name: name, bio: remoteSpeaker.bio, avatar: remoteSpeaker.avatar,
                    twitter: twitter, body: body
                ))
                names.append(name)
            }
            let session = Session(
                title: remote.title, format: remote.format, length: remote.length, room: remote.room,
                startUtc: remote.startUtc, endUtc: remote.endUtc,
                favourite: favourites.contains(id), sessionId: id, videoId: remote.videoId,
                section: remote.startSlot?.asTime() ?? remote.startUtc?.asTime() ?? "00:00",
                registerLoc: remote.registerLoc
            )
            session.speakerNames = names.sorted().joined(separator: ", ")
            context.insert(session)
        }
        try context.save()
    }

    private func fetchSession(_ id: String) -> Session? {
        let descriptor = FetchDescriptor<Session>(predicate: #Predicate { $0.sessionId == id })
        return (try? context.fetch(descriptor))?.first
    }

    private func fetchBody(_ id: String) -> SessionBody? {
        let descriptor = FetchDescriptor<SessionBody>(predicate: #Predicate { $0.sessionId == id })
        return (try? context.fetch(descriptor))?.first
    }

    // MARK: - Fixtures

    private static let sampleJson = """
    {
      "sessions": [
        {
          "sessionId": "s1",
          "title": "Kotlin in anger",
          "abstract": "All about Kotlin",
          "intendedAudience": "Everyone",
          "format": "presentation",
          "length": "45",
          "room": "Room 1",
          "video": "12345",
          "startTimeZulu": "2025-09-03T09:00:00Z",
          "endTimeZulu": "2025-09-03T09:45:00Z",
          "startSlotZulu": "2025-09-03T09:00:00Z",
          "speakers": [
            { "name": "Grace Hopper", "bio": "COBOL", "pictureUrl": "https://example.com/g.png", "twitter": "" },
            { "name": "Ada Lovelace", "bio": "Notes", "pictureUrl": "https://example.com/a.png", "twitter": "@ada" }
          ]
        },
        {
          "title": "Session with no id",
          "format": "presentation"
        },
        {
          "sessionId": "s3",
          "title": "Not yet scheduled",
          "abstract": "TBD",
          "format": "workshop"
        }
      ]
    }
    """

    private static let shrunkJson = """
    {
      "sessions": [
        { "sessionId": "s3", "title": "Not yet scheduled", "abstract": "TBD", "format": "workshop" }
      ]
    }
    """
}
