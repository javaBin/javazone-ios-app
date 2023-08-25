import SwiftUI
import Alamofire
import CoreData
import os.log
import Flurry_iOS_SDK

struct SessionSection : Hashable {
    var startUtc: Date
    var endUtc: Date
    var duration: Int
}

class SessionService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "SessionService")

    private static func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private static func save(context: NSManagedObjectContext) throws {
        if (context.hasChanges) {
            logger.info("Saving changed MOC - Sessions")
            try context.save()
        }
    }
    
    static func refresh() async throws -> UpdateStatus {
        Flurry.log(eventName: "RefreshSessions", timed: true)

        return try await withCheckedThrowingContinuation { continuation in
            refresh { result in
                Flurry.endTimedEvent(eventName: "RefreshSessions", parameters: nil)
                continuation.resume(with: result)
            }
        }
    }
    
    static func refresh(_ onComplete: @escaping (Result<UpdateStatus, Error>) -> Void) {
        ConfigService.refreshConfig() {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let config = Config.sharedConfig
            
            let request = AF.request(config.url)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            logger.debug("Fetching sessions")
            
            request.responseDecodable(of: RemoteSessionList.self, decoder: decoder) { (response) in
                if let error = response.error {
                    logger.error("Unable to fetch sessions \(error.localizedDescription, privacy: .public)")

                    Flurry.log(errorId: "SessionRefreshFailed", message: "Unable to fetch sessions", error: error)
                    
                    onComplete(.failure(ServiceError(status: .Fail, message: "Could not download sessions, please try again")))
                    
                    return
                }
                
                guard let sessions = response.value?.sessions else {
                    logger.error("Unable to read sessions")

                    Flurry.log(errorId: "SessionReadFailed", message: "Unable to read sessions", error: nil)
                    
                    onComplete(.failure(ServiceError(status: .Fail, message: "Could not download sessions, please try again")))
                    
                    return
                }
                
                var favouriteSessions: [Session] = []
                
                logger.debug("Getting favourites")

                do {
                    let request:NSFetchRequest<Session> = Session.fetchRequest() as! NSFetchRequest<Session>

                    request.sortDescriptors = []
                    request.predicate = NSPredicate(format: "favourite == true")
                    
                    favouriteSessions = try context.fetch(request)
                } catch {
                    logger.error("Could not get favourites \(error.localizedDescription, privacy: .public)")
                    // Go forward - we will lose favourites - but may complete
                }
                
                let favourites = favouriteSessions
                    .compactMap { (session) -> String? in
                        return session.sessionId
                }
                
                logger.debug("Got \(favourites.count, privacy: .public) favourites")

                do {
                    logger.debug("Clearing old sessions")

                    let result = try context.execute(Session.clear()) as! NSBatchDeleteResult

                    let changes: [AnyHashable: Any] = [
                        NSDeletedObjectsKey: result.result as! [NSManagedObjectID]
                    ]
                    
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                } catch {
                    logger.error("Could not clear sessions \(error.localizedDescription, privacy: .public)")
                    
                    Flurry.log(errorId: "SessionClaerFailed", message: "Unable to clear session data", error: error)

                    onComplete(.failure(ServiceError(status: .Fatal, message: "Issue in the data store - please delete and reinstall", detail: "Unable to clear session data \(error)")))
                    
                    return
                }
                
                var newSessions : [Session] = []
                
                sessions.forEach { (remoteSession) in
                    if let id = remoteSession.sessionId {
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
                                    if (!twitter.isEmpty) {
                                        speaker.twitter = twitter.deletePrefix("@")
                                    }
                                }

                                speaker.session = session
                            }
                        }
                        
                        newSessions.append(session)
                    }
                }
                
                logger.debug("Saw \(newSessions.count, privacy: .public) new sessions")

                updateSections(newSessions)
                
                do {
                    try save(context: context)
                } catch {
                    logger.error("Could not save sessions \(error.localizedDescription, privacy: .public)")

                    Flurry.log(errorId: "SessionSaveFailed", message: "Unable to save sessions", error: error)

                    onComplete(.failure(ServiceError(status: .Fatal, message: "Issue in the data store - please delete and reinstall", detail: "Unable to save data - sessions \(error)")))

                    return
                }
                
                onComplete(.success(.OK))
            }
        }
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
            if (session.format == "workshop") {
                session.section = session.startUtc?.asDateTime() ?? "00:00"
            } else {
                let sections = allowedSections.filter { (sessionSection) -> Bool in
                    if (session.startUtc == nil || session.endUtc == nil) {
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
