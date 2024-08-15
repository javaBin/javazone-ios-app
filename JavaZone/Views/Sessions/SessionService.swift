import Foundation
import os.log

enum SessionServiceError: Error {
    case refresh
    case parse
}

class SessionService {
    static func refresh() async throws -> [RemoteSession] {
        guard let url = URL(string: Config.sharedConfig.url) else {
            Logger.networking.warning("SessionService: refresh: unable to fetch url from config")
            
            return []
        }

        Logger.networking.info("SessionService: refresh: Refresh")
        
        let cacheBuster = Date().timeIntervalSince1970
        
        let cbUrl = "\(url)?cb=\(cacheBuster)"
        
        Logger.networking.debug("SessionService: refresh: URL: \(cbUrl)")
        
        let sessions: [RemoteSession] = try await URLSession.shared.fetchData(for: cbUrl)
        
        Logger.networking.debug("SessionService: refresh: \(sessions)")
        
        return sessions
    }
}
