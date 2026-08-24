import UIKit
import os.log

@MainActor
final class AvatarCache {
    static let shared = AvatarCache()

    private let logger = Logger(subsystem: Logger.subsystem, category: "AvatarCache")
    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    private var inFlight: [URL: Task<UIImage?, Never>] = [:]

    private init() {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 32 * 1024 * 1024)
        config.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: config)
        cache.countLimit = 200
    }

    func image(for url: URL) async -> UIImage? {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }
        // Coalesce: the same speaker can appear in several visible rows at once.
        if let existing = inFlight[url] {
            return await existing.value
        }

        let task = Task<UIImage?, Never> { [session, logger] in
            do {
                let (data, _) = try await session.data(from: url)
                return UIImage(data: data)
            } catch {
                logger.debug("Avatar fetch failed: \(error.localizedDescription, privacy: .public)")
                return nil
            }
        }
        inFlight[url] = task

        let image = await task.value
        inFlight[url] = nil
        if let image {
            cache.setObject(image, forKey: url as NSURL)
        }
        return image
    }
}
