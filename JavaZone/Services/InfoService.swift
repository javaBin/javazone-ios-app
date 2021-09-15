import Foundation
import Alamofire
import os.log

class InfoService {

    static func refreshConfig(onComplete: @escaping ([RemoteInfo]) -> Void) {
        Logger.network.info("Refreshing info")

        let cacheBuster = Date().timeIntervalSince1970
        
        let request = AF.request("https://gist.githubusercontent.com/chrissearle/a653c7634427142abadee41e0028a047/raw/info.json?cb=\(cacheBuster)")
               
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
               
        request.responseDecodable(of: [RemoteInfo].self, decoder: decoder) { (response) in
            if let error = response.error {
                Logger.network.error("Unable to refresh info \(error.localizedDescription)")
                       
                onComplete([])
                       
                return
           }

            guard let info = response.value else {
                Logger.network.error("Unable to fetch info")

                onComplete([])
            
                return
            }
        
            onComplete(info)
        }
    }
}
