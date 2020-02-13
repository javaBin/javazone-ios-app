import Foundation
import Alamofire

class SessionService {
    func getAll() {
        let request = AF.request("https://sleepingpill.javazone.no/public/allSessions/javazone_2019")
        
        request.responseJSON { (data) in
          print(data)
        }
        
    }
}
