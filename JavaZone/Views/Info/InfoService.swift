import Foundation
import os.log

struct InfoService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "InfoService")

    static func refresh() async throws -> [RemoteInfo] {
        logger.info("Refreshing info")
        let cacheBuster = Date().timeIntervalSince1970
        let url = URL(string: "https://javabin.github.io/javazone-ios-app/info.json?cb=\(cacheBuster)")!
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        URLCache.shared.removeCachedResponse(for: request)
        return try JSONDecoder().decode([RemoteInfo].self, from: data)
    }
}
