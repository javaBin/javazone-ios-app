import Foundation
import Alamofire
import os.log

class InfoService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "InfoService")

    static func refreshConfig(onComplete: @escaping ([RemoteInfo]) -> Void) {
        logger.info("Refreshing info")

        let cacheBuster = Date().timeIntervalSince1970
        
        let request = AF.request("https://gist.githubusercontent.com/chrissearle/a653c7634427142abadee41e0028a047/raw/info.json?cb=\(cacheBuster)")
               
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
               
        request.responseDecodable(of: [RemoteInfo].self, decoder: decoder) { (response) in
            if let error = response.error {
                logger.error("Unable to refresh info \(error.localizedDescription, privacy: .public)")
                       
                onComplete([])
                       
                return
           }

            guard let info = response.value else {
                logger.error("Unable to fetch info")

                onComplete([])
            
                return
            }
        
            onComplete(info)
        }
    }
}
