import Foundation
import SwiftData
import os.log

enum SessionError: Error {
    case fail(String)
    case fatal(String, String)
}

struct SessionService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "SessionService")

    @MainActor
    static func refresh(context: ModelContext, appConfig: AppConfig) async throws {
        if let remoteConfig = try? await ConfigService.refresh() {
            appConfig.apply(remote: remoteConfig)
        }

        guard let sessionUrl = URL(string: appConfig.url) else {
            throw SessionError.fail("Invalid session URL")
        }

        let data = try await fetchData(from: sessionUrl)
        let sessionList = try decodeSessionList(from: data)

        // Fetch only favourite sessions — avoids loading all session abstracts into memory.
        let favouriteDescriptor = FetchDescriptor<Session>(predicate: #Predicate { $0.favourite == true })
        let favouriteSessions = (try? context.fetch(favouriteDescriptor)) ?? []
        let favourites = Set(favouriteSessions.compactMap(\.sessionId))
        logger.debug("Got \(favourites.count, privacy: .public) favourites")

        // Batch delete speakers first so no Speaker.session inverse references remain,
        // then sessions. Neither operation loads objects into memory.
        try? context.delete(model: Speaker.self)
        try? context.delete(model: Session.self)

        for remoteSession in sessionList.sessions {
            guard let id = remoteSession.sessionId else { continue }
            let session = buildSession(from: remoteSession, id: id, favourites: favourites)
            context.insert(session)
            insertSpeakers(from: remoteSession, into: session, context: context)
        }

        logger.debug("Saved \(sessionList.sessions.count, privacy: .public) sessions")
        try context.save()
    }

    // MARK: - Private helpers

    private static func fetchData(from url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            logger.error("Network error: \(error.localizedDescription, privacy: .public)")
            throw SessionError.fail("Could not download sessions, please try again")
        }
    }

    private static func decodeSessionList(from data: Data) throws -> RemoteSessionList {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(RemoteSessionList.self, from: data)
        } catch {
            logger.error("Decode error: \(error.localizedDescription, privacy: .public)")
            throw SessionError.fail("Could not download sessions, please try again")
        }
    }

    private static func buildSession(
        from remote: RemoteSession,
        id: String,
        favourites: Set<String>
    ) -> Session {
        Session(
            title: remote.title,
            abstract: remote.abstract,
            audience: remote.audience,
            format: remote.format,
            length: remote.length,
            room: remote.room,
            startUtc: remote.startUtc,
            endUtc: remote.endUtc,
            favourite: favourites.contains(id),
            sessionId: id,
            videoId: remote.videoId,
            section: remote.startSlot?.asTime() ?? remote.startUtc?.asTime() ?? "00:00",
            registerLoc: remote.registerLoc,
            workshopPrerequisites: remote.workshopPrerequisites
        )
    }

    private static func insertSpeakers(
        from remote: RemoteSession,
        into session: Session,
        context: ModelContext
    ) {
        var names: [String] = []
        for remoteSpeaker in remote.speakers ?? [] {
            guard let name = remoteSpeaker.name else { continue }
            let twitter: String? = {
                guard let handle = remoteSpeaker.twitter, !handle.isEmpty else { return nil }
                return handle.deletePrefix("@")
            }()
            context.insert(Speaker(
                name: name,
                bio: remoteSpeaker.bio,
                avatar: remoteSpeaker.avatar,
                twitter: twitter,
                session: session
            ))
            names.append(name)
        }
        session.speakerNames = names.sorted().joined(separator: ", ")
    }
}
