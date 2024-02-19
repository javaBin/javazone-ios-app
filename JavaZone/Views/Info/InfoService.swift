import Foundation
import os.log

enum InfoError: Error {
    case refresh
    case parse
}

class InfoService {
    static func refresh() async throws -> [RemoteInfo] {
        Logger.networking.info("InfoService: refresh: Refresh")

        let cacheBuster = Date().timeIntervalSince1970

        let url = "https://javabin.github.io/javazone-ios-app/info.json?cb=\(cacheBuster)"

        Logger.networking.debug("InfoService: refresh: URL: \(url)")

        let info: [RemoteInfo] = try await URLSession.shared.fetchData(for: url)

        Logger.networking.debug("InfoService: refresh: \(info)")

        return info
    }
}
