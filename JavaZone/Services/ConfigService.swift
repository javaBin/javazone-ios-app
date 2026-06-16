import Foundation
import os.log

struct ConfigService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "ConfigService")

    static func refresh() async throws -> RemoteConfig {
        logger.info("Refreshing config")
        let url = URL(string: "https://sleepingpill.javazone.no/public/config")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(RemoteConfig.self, from: data)
    }
}
