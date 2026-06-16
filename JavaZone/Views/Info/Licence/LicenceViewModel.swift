import Foundation
import os.log

@Observable
@MainActor
final class LicenceViewModel {
    private let logger = Logger(subsystem: Logger.subsystem, category: "LicenceViewModel")
    var licences: [Licence] = []

    func load() {
        guard let url = Bundle.main.url(forResource: "licences", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            logger.error("licences.json not found or unreadable")
            return
        }
        do {
            licences = try JSONDecoder().decode([Licence].self, from: data)
        } catch {
            logger.error("Failed to decode licences: \(error.localizedDescription, privacy: .public)")
        }
    }
}
