import SwiftUI
import Alamofire
import CoreData
import os.log

struct SessionSection: Hashable {
    var startUtc: Date
    var endUtc: Date
    var duration: Int
}

class SessionService {
    // swiftlint:disable force_cast
    private static func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    // swiftlint:enable force_cast

    private static func save(context: NSManagedObjectContext) throws {
        if context.hasChanges {
            Logger.datastore.info("SessionService: save: Saving changed MOC - Sessions")
            try context.save()
        }
    }

    static func refresh() async throws -> UpdateStatus {
        return try await withCheckedThrowingContinuation { continuation in
            refresh { result in
                continuation.resume(with: result)
            }
        }
    }

    static func refresh(_ onComplete: @escaping (Result<UpdateStatus, Error>) -> Void) {
        ConfigService.refreshConfig {
            // swiftlint:disable force_cast
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            // swiftlint:enable force_cast

            let request = AF.request(Config.sharedConfig.url)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            Logger.networking.debug("SessionService: refresh: Fetching sessions")

            request.responseDecodable(of: RemoteSessionList.self, decoder: decoder) { (response) in
                if let error = response.error {
                    Logger.networking.error("""
SessionService: refresh: Unable to fetch sessions \(error.localizedDescription, privacy: .public)
"""
                    )

                    onComplete(.failure(ServiceError(status: .fail,
                                                     message: "Could not download sessions, please try again")))

                    return
                }

                guard let sessions = response.value?.sessions else {
                    Logger.networking.error("SessionService: refresh: Unable to read sessions")

                    onComplete(.failure(ServiceError(status: .fail,
                                                     message: "Could not download sessions, please try again")))

                    return
                }

                let favourites = getFavourites(context: context)

                if !clearOldSessions(context: context, onComplete: onComplete) { return }

                var newSessions: [Session] = []

                sessions.forEach { (remoteSession) in
                    if let session = buildSession(session: remoteSession, favourites: favourites, context: context) {
                        newSessions.append(session)
                    }
                }

                Logger.networking.debug("""
SessionService: refresh: Saw \(newSessions.count, privacy: .public) new sessions
"""
                )

                updateSections(newSessions)

                do {
                    try save(context: context)
                } catch {
                    Logger.datastore.error("""
SessionService: refresh: Could not save sessions \(error.localizedDescription, privacy: .public)
"""
                    )

                    onComplete(.failure(ServiceError(status: .fatal,
                                                     message: "Issue in the data store - please delete and reinstall",
                                                     detail: "Unable to save data - sessions \(error)")))

                    return
                }

                onComplete(.success(.success))
            }
        }
    }

    private static func clearOldSessions(context: NSManagedObjectContext,
                                         onComplete: @escaping (Result<UpdateStatus, Error>) -> Void) -> Bool {
        do {
            Logger.datastore.debug("SessionService: refresh: Clearing old sessions")

            // swiftlint:disable force_cast
            let result = try context.execute(Session.clear()) as! NSBatchDeleteResult
            // swiftlint:enable force_cast

            let changes: [AnyHashable: Any] = [
                // swiftlint:disable force_cast
                NSDeletedObjectsKey: result.result as! [NSManagedObjectID]
                // swiftlint:enable force_cast
            ]

            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])

            return true
        } catch {
            Logger.datastore.error("""
SessionService: refresh: Could not clear sessions \(error.localizedDescription, privacy: .public)
"""
            )

            onComplete(.failure(ServiceError(status: .fatal,
                                             message: "Issue in the data store - please delete and reinstall",
                                             detail: "Unable to clear session data \(error)")))

            return false
        }
    }

    private static func getFavourites(context: NSManagedObjectContext) -> [String] {
        Logger.datastore.debug("SessionService: refresh: Getting favourites")

        do {
            // swiftlint:disable force_cast
            let request: NSFetchRequest<Session> = Session.fetchRequest() as! NSFetchRequest<Session>
            // swiftlint:enable force_cast

            request.sortDescriptors = []
            request.predicate = NSPredicate(format: "favourite == true")

            let favouriteSessions = try context.fetch(request)

            let favourites = favouriteSessions
                .compactMap { (session) -> String? in
                    return session.sessionId
            }

            Logger.datastore.debug("SessionService: refresh: Got \(favourites.count, privacy: .public) favourites")

            return favourites
        } catch {
            Logger.datastore.error("""
SessionService: refresh: Could not get favourites \(error.localizedDescription, privacy: .public)
""")
            // Go forward - we will lose favourites - but may complete

            return []
        }
    }

    private static func buildSession(session remoteSession: RemoteSession, favourites: [String],
                                     context: NSManagedObjectContext) -> Session? {
        guard let id = remoteSession.sessionId else {
            return nil
        }

        let session = Session(context: context)

        session.sessionId = id
        session.abstract = remoteSession.abstract
        session.audience = remoteSession.audience
        session.format = remoteSession.format
        session.title = remoteSession.title
        session.length = remoteSession.length
        session.room = remoteSession.room
        session.startUtc = remoteSession.startUtc
        session.endUtc = remoteSession.endUtc
        session.section = session.startUtc?.asHour() ?? "00:00"
        session.registerLoc = remoteSession.registerLoc
        session.workshopPrerequisites = remoteSession.workshopPrerequisites
        session.videoId = remoteSession.videoId

        session.favourite = favourites.contains(id)

        remoteSession.speakers?.forEach { (remoteSpeaker) in
            let speaker = Speaker(context: context)

            if let name = remoteSpeaker.name {
                speaker.name = name
                speaker.bio = remoteSpeaker.bio
                speaker.avatar = remoteSpeaker.avatar

                if let twitter = remoteSpeaker.twitter {
                    if !twitter.isEmpty {
                        speaker.twitter = twitter.deletePrefix("@")
                    }
                }

                speaker.session = session
            }
        }

        return session
    }

    private static func updateSections(_ sessions: [Session]) {
        let allowedSections = Set(sessions.filter { (session) -> Bool in
            session.format == "presentation"
        }.filter { (session) -> Bool in
            session.startUtc != nil
        }.filter { (session) -> Bool in
            session.endUtc != nil
        }.filter { (session) -> Bool in
            session.length != nil && Int(session.length!) != nil
        }.map { (session) -> SessionSection in
            SessionSection(startUtc: session.startUtc!, endUtc: session.endUtc!, duration: Int(session.length!) ?? 0)
        })

        sessions.forEach { (session) in
            if session.format == "workshop" {
                session.section = session.startUtc?.asDateTime() ?? "00:00"
            } else {
                let sections = allowedSections.filter { (sessionSection) -> Bool in
                    if session.startUtc == nil || session.endUtc == nil {
                        return false
                    }

                    return session.startUtc! >= sessionSection.startUtc && session.endUtc! <= sessionSection.endUtc
                }.sorted { (first, second) -> Bool in
                    first.duration > second.duration
                }

                if let section = sections.first {
                    session.section = "\(section.startUtc.asTime()) - \(section.endUtc.asTime())"
                }
            }
        }
    }
}
