import Foundation
import Alamofire
import os

class InfoService {

    static func refreshConfig(onComplete: @escaping ([RemoteInfo]) -> Void) {
        os_log("Refreshing info", log: .network, type: .info)

        let request = AF.request("https://www.java.no/javazone-ios-app/info.json")
               
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
               
        request.responseDecodable(of: [RemoteInfo].self, decoder: decoder) { (response) in
            if let error = response.error {
                os_log("Unable to refresh info %{public}@", log: .network, type: .error, error.localizedDescription)
                       
                onComplete([])
                       
                return
           }

            guard let info = response.value else {
                os_log("Unable to fetch info", log: .network, type: .error)

                onComplete([])
            
                return
            }
        
            onComplete(info)
        }
    }
}
