import SwiftUI
import Alamofire
import CoreData

enum SessionError : Error {
    case remoteError
    case parseError
    case storageError
}

struct SessionSection : Hashable {
    var startUtc: Date
    var endUtc: Date
    var duration: Int
}

enum UpdateStatus {
    case OK
    case Fail
    case Fatal
}

class SessionService {
    private static func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private static func save(context: NSManagedObjectContext) throws {
        if (context.hasChanges) {
            try context.save()
        }
    }
    
    static func refresh(onComplete : @escaping (_ status: UpdateStatus, _ msg: String, _ logMsg: String) -> Void) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request = AF.request(Config.conferenceUrl)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        request.responseDecodable(of: RemoteSessionList.self, decoder: decoder) { (response) in
            if let error = response.error {
                print(error.localizedDescription)
                
                onComplete(.Fail, "Could not download sessions, please try again", "")
                
                return
            }
            
            guard let sessions = response.value?.sessions else {
                print("Unable to fetch sessions")

                onComplete(.Fail, "Could not download sessions, please try again", "")
                
                return
            }
            
            var favouriteSessions: [Session] = []
            
            do {
                let request:NSFetchRequest<Session> = Session.fetchRequest() as! NSFetchRequest<Session>

                request.sortDescriptors = []
                request.predicate = NSPredicate(format: "favourite == true")
                
                favouriteSessions = try context.fetch(request)
            } catch {
                print("Could not get favourites: \(error).")
                
                // Go forward - we will lose favourites - but may complete
            }
            
            let favourites = favouriteSessions
                .compactMap { (session) -> String? in
                    return session.sessionId
            }
            
            do {
                let result = try context.execute(Session.clear()) as! NSBatchDeleteResult

                let changes: [AnyHashable: Any] = [
                    NSDeletedObjectsKey: result.result as! [NSManagedObjectID]
                ]
                
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            } catch {
                print("Could not clear: \(error).")
                
                onComplete(.Fatal, "Issue in the data store - please delete and reinstall", "Unable to clear data \(error)")
                
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
            
            updateSections(newSessions)
            
            do {
                try save(context: context)
            } catch {
                onComplete(.Fatal, "Issue in the data store - please delete and reinstall", "Unable to save data \(error)")

                return
            }
            
            onComplete(.OK, "", "")
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
