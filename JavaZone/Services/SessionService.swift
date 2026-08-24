import Foundation
import SwiftData
import os.log

enum SessionError: Error {
    case fail(String)
}

struct SessionService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "SessionService")

    @MainActor
    static func refresh(context: ModelContext, appConfig: AppConfig) async throws {
        // A config from an earlier launch is still usable, so neither a failed download nor
        // a corrupt payload aborts the refresh — only having no config at all does.
        do {
            let remoteConfig = try await ConfigService.refresh()
            if !appConfig.apply(remote: remoteConfig) {
                logger.error("Corrupt config download — continuing with the stored config")
            }
        } catch {
            logger.error("Config refresh failed: \(error.localizedDescription, privacy: .public)")
        }

        guard !appConfig.url.isEmpty else {
            throw SessionError.fail("Could not reach JavaZone, please check your connection and try again")
        }

        guard let sessionUrl = URL(string: appConfig.url) else {
            throw SessionError.fail("Invalid session URL")
        }

        let data = try await fetchData(from: sessionUrl)
        let sessionList = try await decodeSessionList(from: data)

        let favouriteDescriptor = FetchDescriptor<Session>(predicate: #Predicate { $0.favourite == true })
        let favourites = Set(((try? context.fetch(favouriteDescriptor)) ?? []).compactMap(\.sessionId))
        logger.debug("Got \(favourites.count, privacy: .public) favourites")

        // Both sides of the SessionBody.speakers relationship are optional ([Speaker]? and
        // SessionBody?), so context.delete(model:) can nullify the inverse without hitting
        // a NOT NULL constraint. Delete Speakers first so SessionBody cascade has nothing
        // left to process.
        try? context.delete(model: Speaker.self)
        try? context.delete(model: SessionBody.self)
        try? context.delete(model: Session.self)

        for remoteSession in sessionList.sessions {
            guard let id = remoteSession.sessionId else { continue }
            let body = SessionBody(
                sessionId: id,
                abstract: remoteSession.abstract,
                audience: remoteSession.audience,
                workshopPrerequisites: remoteSession.workshopPrerequisites
            )
            context.insert(body)
            let session = buildSession(from: remoteSession, id: id, favourites: favourites)
            context.insert(session)
            insertSpeakers(from: remoteSession, into: body, settingNamesOn: session, context: context)
        }

        logger.debug("Saved \(sessionList.sessions.count, privacy: .public) sessions")
        try context.save()

        // Session times move and sessions get dropped between refreshes, so the pending
        // reminders are rebuilt from what is now in the store rather than left stale.
        await NotificationScheduler.reconcile(favourites: reminders(in: context))
    }

    @MainActor
    private static func reminders(in context: ModelContext) -> [NotificationScheduler.Reminder] {
        let descriptor = FetchDescriptor<Session>(predicate: #Predicate { $0.favourite == true })
        return ((try? context.fetch(descriptor)) ?? []).compactMap { session in
            guard let sessionId = session.sessionId, let start = session.startUtc else { return nil }
            return NotificationScheduler.Reminder(
                sessionId: sessionId,
                title: session.wrappedTitle,
                room: session.wrappedRoom,
                start: start
            )
        }
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

    private static func decodeSessionList(from data: Data) async throws -> RemoteSessionList {
        do {
            return try await Task.detached(priority: .userInitiated) {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(RemoteSessionList.self, from: data)
            }.value
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
            format: remote.format,
            length: remote.length,
            room: remote.room,
            startUtc: remote.startUtc,
            endUtc: remote.endUtc,
            favourite: favourites.contains(id),
            sessionId: id,
            videoId: remote.videoId,
            section: remote.startSlot?.asTime() ?? remote.startUtc?.asTime() ?? "00:00",
            registerLoc: remote.registerLoc
        )
    }

    private static func insertSpeakers(
        from remote: RemoteSession,
        into body: SessionBody,
        settingNamesOn session: Session,
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
                body: body
            ))
            names.append(name)
        }
        session.speakerNames = names.sorted().joined(separator: ", ")
    }
}
