import Foundation
import os.log

enum InfoError: Error {
    case refresh
    case parse
}

class InfoService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "InfoService")

    static func refresh() async throws -> [RemoteInfo] {
        logger.info("Info: Refresh")

        let cacheBuster = Date().timeIntervalSince1970

        let url = "https://javabin.github.io/javazone-ios-app/info.json?cb=\(cacheBuster)"

        logger.debug("Info: URL: \(url)")

        let info: [RemoteInfo] = try await URLSession.shared.fetchData(for: url)

        logger.debug("Info: \(info)")

        return info
    }
}
