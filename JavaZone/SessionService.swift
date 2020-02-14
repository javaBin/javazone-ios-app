import Foundation
import Alamofire
import CoreData

enum SessionError : Error {
    case remoteError
    case parseError
    case storageError
}

class SessionService {
    private static func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private static func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Could not save: \(error).")
        }
    }
    
    static func clear() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        do {
            try context.execute(Session.clear())
        } catch {
            print("Could not clear: \(error).")
            
            return
        }
        
        save(context: context)
    }
    
    static func refresh() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request = AF.request("https://sleepingpill.javazone.no/public/allSessions/javazone_2019")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        request.responseDecodable(of: RemoteSessionList.self, decoder: decoder) { (response) in
            if let error = response.error {
                print(error.localizedDescription)
            }
            
            guard let sessions = response.value else { return }
            
            let fetchedSessions = sessions.sessions
            
            var favouriteSessions: [Session] = []
            
            do {
                favouriteSessions = try context.fetch(Session.getFavourites())
            } catch {
                print("Could not get favourites: \(error).")
                
                return
            }
            
            print("Favourites: \(favouriteSessions)")
            
            let favourites = favouriteSessions
                .compactMap { (session) -> String? in
                    return session.sessionId
            }
            
            do {
                try context.execute(Session.clear())
            } catch {
                 print("Could not clear: \(error).")
                
                return
            }
            
            fetchedSessions.forEach { (remoteSession) in
                if let id = remoteSession.sessionId {
                    print("Creating: \(id)")

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
                    
                    session.favourite = favourites.contains(id)
                    
                    remoteSession.speakers?.forEach { (remoteSpeaker) in
                        let speaker = Speaker(context: context)
                        
                        if let name = remoteSpeaker.name {
                            speaker.name = name

                            speaker.bio = remoteSpeaker.bio
                            
                            if let url = remoteSpeaker.avatar {
                                speaker.avatar = url
                            }
                            
                            speaker.twitter = remoteSpeaker.twitter
                        
                            session.speakers.insert(speaker)
                        }
                    }
                    
                    print("Favourite flag for \(id) was \(session.favourite)")
                }
            }
            
            save(context: context)
        }
    }
}
