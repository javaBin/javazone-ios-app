import Foundation
import Alamofire

class SessionService {
    func getAll() {
        let request = AF.request("https://sleepingpill.javazone.no/public/allSessions/javazone_2019")
        
        request.responseDecodable(of: RemoteSessionList.self) { (response) in
            guard let sessions = response.value else { return }
            
            sessions.sessions.forEach {
                print("\($0.title!)")
                print("\($0.speakers?.count)")
            }
        }
    }
}
