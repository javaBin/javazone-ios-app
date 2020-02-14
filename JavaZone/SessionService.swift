import Foundation
import Alamofire
import CoreData

enum SessionError : Error {
    case remoteError
    case parseError
    case storageError
}

class SessionService {
    static func refresh() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request = AF.request("https://sleepingpill.javazone.no/public/allSessions/javazone_2019")
        
        request.responseDecodable(of: RemoteSessionList.self) { (response) in
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
                }
            }
            
            do {
                try context.save()
            } catch {
                print("Could not save: \(error).")
                
            }
        }
    }
}
