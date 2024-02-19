import SwiftUI
import OSLog

class LicenceViewModel: ObservableObject {
    @Published var licences: [Licence] = []

    init() {
        Logger.licencing.debug("LicenceViewModel: init: Loading licences")
        ConfigService.loadLocalJsonFile(name: "licences") { (licences: [Licence]) in
            Logger.licencing.debug("LicenceViewModel: init: Loaded licences \(licences)")
            self.licences = licences
        }
    }
}
