import Foundation
import Alamofire
import os.log
import Flurry_iOS_SDK

enum InfoError : Error {
    case refresh
    case parse
}

class InfoService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "InfoService")

    
    static func refresh() async throws -> [RemoteInfo] {
        Flurry.log(eventName: "RefreshInfo", timed: true)
        
        return try await withCheckedThrowingContinuation { continuation in
            refresh { result in
                Flurry.endTimedEvent(eventName: "RefreshInfo", parameters: nil)
                continuation.resume(with: result)
            }
        }
    }
    
    static func refresh(_ onComplete: @escaping (Result<[RemoteInfo], Error>) -> Void) {
        logger.info("Refreshing info")

        let cacheBuster = Date().timeIntervalSince1970
        
        let request = AF.request("https://javabin.github.io/javazone-ios-app/info.json?cb=\(cacheBuster)")
               
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
               
        request.responseDecodable(of: [RemoteInfo].self, decoder: decoder) { (response) in
            if let error = response.error {
                logger.error("Unable to refresh info \(error.localizedDescription, privacy: .public)")
                
                Flurry.log(errorId: "InfoRefreshFailed", message: "Unable to refresh info", error: error)
                
                onComplete(.failure(InfoError.refresh))
                       
                return
           }

            guard let info = response.value else {
                logger.error("Unable to fetch info")

                Flurry.log(errorId: "SessionFetchFailed", message: "Unable to fetch sessions", error: nil)
                
                onComplete(.failure(InfoError.parse))
            
                return
            }
        
            onComplete(.success(info))
        }
    }
}
