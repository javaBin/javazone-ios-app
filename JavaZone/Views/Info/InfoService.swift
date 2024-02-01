import Foundation
import Alamofire
import os.log

enum InfoError: Error {
    case refresh
    case parse
}

class InfoService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "InfoService")

    static func refresh() async throws -> [RemoteInfo] {
        return try await withCheckedThrowingContinuation { continuation in
            refresh { result in
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

                onComplete(.failure(InfoError.refresh))

                return
           }

            guard let info = response.value else {
                logger.error("Unable to fetch info")

                onComplete(.failure(InfoError.parse))

                return
            }

            onComplete(.success(info))
        }
    }
}
