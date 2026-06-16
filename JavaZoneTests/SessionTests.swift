import XCTest
import SwiftData
@testable import JavaZone

// Tests for Session computed properties.
// Tests that require relationship tracking use an in-memory ModelContainer.
final class SessionTests: XCTestCase {

    // MARK: - wrappedTitle

    func testWrappedTitleNilReturnsEmpty() {
        let session = Session()
        XCTAssertEqual(session.wrappedTitle, "")
    }

    func testWrappedTitleTrimsWhitespace() {
        let session = Session(title: "  JavaZone Talk  ")
        XCTAssertEqual(session.wrappedTitle, "JavaZone Talk")
    }

    func testWrappedTitleReturnsValue() {
        let session = Session(title: "Lessons from the Columbia Space Shuttle")
        XCTAssertEqual(session.wrappedTitle, "Lessons from the Columbia Space Shuttle")
    }

    // MARK: - wrappedAbstract

    func testWrappedAbstractNilReturnsEmpty() {
        XCTAssertEqual(Session().wrappedAbstract, "")
    }

    func testWrappedAbstractTrimsNewlines() {
        let session = Session(abstract: "\n  Abstract body\n")
        XCTAssertEqual(session.wrappedAbstract, "Abstract body")
    }

    // MARK: - wrappedAudience

    func testWrappedAudienceNilReturnsEmpty() {
        XCTAssertEqual(Session().wrappedAudience, "")
    }

    func testWrappedAudienceTrimsWhitespace() {
        let session = Session(audience: "  Intermediate  ")
        XCTAssertEqual(session.wrappedAudience, "Intermediate")
    }

    // MARK: - wrappedRoom / wrappedSection

    func testWrappedRoomNilReturnsEmpty() {
        XCTAssertEqual(Session().wrappedRoom, "")
    }

    func testWrappedRoomReturnsValue() {
        XCTAssertEqual(Session(room: "Room 1").wrappedRoom, "Room 1")
    }

    func testWrappedSectionNilReturnsQuestionMarks() {
        XCTAssertEqual(Session().wrappedSection, "??")
    }

    func testWrappedSectionReturnsSlotTime() {
        XCTAssertEqual(Session(section: "09:20").wrappedSection, "09:20")
    }

    // MARK: - format flags

    func testLightningTalkFormat() {
        let session = Session(format: "lightning-talk")
        XCTAssertTrue(session.lightningTalk)
        XCTAssertFalse(session.workshop)
    }

    func testWorkshopFormat() {
        let session = Session(format: "workshop")
        XCTAssertTrue(session.workshop)
        XCTAssertFalse(session.lightningTalk)
    }

    func testPresentationIsNeitherFlag() {
        let session = Session(format: "presentation")
        XCTAssertFalse(session.lightningTalk)
        XCTAssertFalse(session.workshop)
    }

    func testNilFormatIsNeitherFlag() {
        let session = Session()
        XCTAssertFalse(session.lightningTalk)
        XCTAssertFalse(session.workshop)
    }

    // MARK: - wrappedVideo

    func testWrappedVideoNilVideoIdReturnsNil() {
        XCTAssertNil(Session().wrappedVideo)
    }

    func testWrappedVideoBuildsVimeoURL() {
        let session = Session(videoId: "987654321")
        XCTAssertEqual(session.wrappedVideo, URL(string: "https://vimeo.com/987654321"))
    }

    // MARK: - wrappedRegisterLoc

    func testWrappedRegisterLocNilReturnsNil() {
        XCTAssertNil(Session().wrappedRegisterLoc)
    }

    func testWrappedRegisterLocBuildsURL() {
        let session = Session(registerLoc: "https://example.com/register")
        XCTAssertEqual(session.wrappedRegisterLoc, URL(string: "https://example.com/register"))
    }

    // MARK: - wrappedWorkshopPrerequisites

    func testWrappedWorkshopPrerequisitesNilReturnsEmpty() {
        XCTAssertEqual(Session().wrappedWorkshopPrerequisites, "")
    }

    func testWrappedWorkshopPrerequisitesReturnsValue() {
        let session = Session(workshopPrerequisites: "Basic Swift knowledge")
        XCTAssertEqual(session.wrappedWorkshopPrerequisites, "Basic Swift knowledge")
    }

    // MARK: - notYetStarted

    func testNotYetStartedFutureSessionReturnsTrue() {
        let session = Session(startUtc: Date().addingTimeInterval(3600))
        XCTAssertTrue(session.notYetStarted())
    }

    func testNotYetStartedPastSessionReturnsFalse() {
        let session = Session(startUtc: Date().addingTimeInterval(-3600))
        XCTAssertFalse(session.notYetStarted())
    }

    func testNotYetStartedNilStartDateReturnsFalse() {
        XCTAssertFalse(Session().notYetStarted())
    }

    // MARK: - speakerArray (requires relationship context)

    @MainActor
    func testSpeakerArraySortedByName() throws {
        let container = try ModelContainer(
            for: Session.self, Speaker.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let session = Session(title: "Test", sessionId: "s1")
        context.insert(session)
        context.insert(Speaker(name: "Charlie", session: session))
        context.insert(Speaker(name: "Alice", session: session))
        context.insert(Speaker(name: "Bob", session: session))
        try context.save()

        XCTAssertEqual(session.speakerArray.map(\.wrappedName), ["Alice", "Bob", "Charlie"])
    }

    @MainActor
    func testSpeakerNamesJoinedSorted() throws {
        let container = try ModelContainer(
            for: Session.self, Speaker.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let session = Session(title: "Test", sessionId: "s1")
        context.insert(session)
        context.insert(Speaker(name: "Zara", session: session))
        context.insert(Speaker(name: "Alice", session: session))
        try context.save()

        XCTAssertEqual(session.speakerNames, "Alice, Zara")
    }

    @MainActor
    func testSpeakerNamesEmptyWhenNoSpeakers() throws {
        let container = try ModelContainer(
            for: Session.self, Speaker.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let session = Session(title: "Test", sessionId: "s1")
        context.insert(session)
        try context.save()

        XCTAssertEqual(session.speakerNames, "")
    }
}
