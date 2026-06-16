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
        // Refresh config first (best-effort — failures don't abort the session fetch)
        if let remoteConfig = try? await ConfigService.refresh() {
            appConfig.apply(remote: remoteConfig)
        }

        guard let sessionUrl = URL(string: appConfig.url) else {
            throw SessionError.fail("Invalid session URL")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(from: sessionUrl)
        } catch {
            logger.error("Network error: \(error.localizedDescription, privacy: .public)")
            throw SessionError.fail("Could not download sessions, please try again")
        }

        let sessionList: RemoteSessionList
        do {
            sessionList = try decoder.decode(RemoteSessionList.self, from: data)
        } catch {
            logger.error("Decode error: \(error.localizedDescription, privacy: .public)")
            throw SessionError.fail("Could not download sessions, please try again")
        }

        // Preserve favourites before clearing
        let existingSessions = (try? context.fetch(FetchDescriptor<Session>())) ?? []
        let favourites = Set(existingSessions.filter(\.favourite).compactMap(\.sessionId))
        logger.debug("Got \(favourites.count, privacy: .public) favourites")

        // Delete individually so relationship inverse rules fire correctly.
        // Batch delete (context.delete(model:)) skips relationship nullification
        // and triggers a constraint error when Speaker.session is involved.
        let existingSpeakers = (try? context.fetch(FetchDescriptor<Speaker>())) ?? []
        existingSpeakers.forEach { context.delete($0) }
        existingSessions.forEach { context.delete($0) }
        logger.debug("Cleared old sessions")

        var newSessions: [Session] = []

        for remoteSession in sessionList.sessions {
            guard let id = remoteSession.sessionId else { continue }

            let session = Session(
                title: remoteSession.title,
                abstract: remoteSession.abstract,
                audience: remoteSession.audience,
                format: remoteSession.format,
                length: remoteSession.length,
                room: remoteSession.room,
                startUtc: remoteSession.startUtc,
                endUtc: remoteSession.endUtc,
                favourite: favourites.contains(id),
                sessionId: id,
                videoId: remoteSession.videoId,
                section: remoteSession.startSlot?.asTime() ?? remoteSession.startUtc?.asTime() ?? "00:00",
                registerLoc: remoteSession.registerLoc,
                workshopPrerequisites: remoteSession.workshopPrerequisites
            )
            context.insert(session)

            for remoteSpeaker in remoteSession.speakers ?? [] {
                guard let name = remoteSpeaker.name else { continue }
                let twitter: String? = {
                    guard let handle = remoteSpeaker.twitter, !handle.isEmpty else { return nil }
                    return handle.deletePrefix("@")
                }()
                let speaker = Speaker(
                    name: name,
                    bio: remoteSpeaker.bio,
                    avatar: remoteSpeaker.avatar,
                    twitter: twitter,
                    session: session
                )
                context.insert(speaker)
            }

            newSessions.append(session)
        }

        logger.debug("Inserted \(newSessions.count, privacy: .public) sessions")
        try context.save()
    }
}
