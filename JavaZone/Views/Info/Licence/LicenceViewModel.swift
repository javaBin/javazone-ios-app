import SwiftUI
import OSLog

class LicenceViewModel: ObservableObject {
    let logger = Logger(subsystem: Logger.subsystem, category: "LicenceViewModel")

    @Published var licences: [Licence] = []

    init() {
        logger.debug("Loading licences")
        ConfigService.loadLocalJsonFile(name: "licences") { (licences: [Licence]) in
            self.logger.debug("Loaded licences \(licences)")
            self.licences = licences
        }
    }
}
