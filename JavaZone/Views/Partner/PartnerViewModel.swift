import SwiftUI
import Combine
import os.log

class PartnerViewModel : ObservableObject {
    let logger = Logger(subsystem: Logger.subsystem, category: "PartnerViewModel")
    private let idiom = UIDevice.current.userInterfaceIdiom

    @Published var displayPartners : [Partner] = []
    @Published var partners : [Partner] = [] {
        willSet {
            logger.info("Updating partners to \(newValue)")
            displayPartners = newValue.shuffled()
        }
    }
        
    @Published var alertItem : AlertItem?
    @Published var cols : Int = 3
    
    private var cancellable : AnyCancellable?
    
    init(partnerPublisher: AnyPublisher<[Partner], Never> = PartnerStorage.shared.partners.eraseToAnyPublisher()) {
        cancellable = partnerPublisher.sink { partners in
            self.logger.info("Updating partners")
            self.partners = partners
        }
        
        setOrientation(UIDevice.current.orientation)
    }
    
    func refreshPartners(force: Bool = false) {
        PartnerService.refresh(force: force) { (status, message, logMessage) in
            
            // If we fail to fetch but have partners _ this list changes so rarely that we ignore and continue.
            if (status == .Fail && self.partners.count == 0) {
                self.alertItem = AlertContext.build(title: "Refresh failed", message: message, buttonTitle: "OK")
            }
            
            if (status == .Fatal) {
                self.alertItem = AlertContext.buildFatal(title: "Refresh failed", message: message, buttonTitle: "OK", fatalMessage: logMessage)
            }
        }
    }
    
    func setOrientation(_ orientation: UIDeviceOrientation) {
        var isPortrait: Bool?
        
        switch (orientation) {
        case .portrait, .portraitUpsideDown: isPortrait = true
        case .landscapeLeft, .landscapeRight: isPortrait = false
        default:
            break
        }
        
        if let isPortrait = isPortrait {
            calculateCols(isPortrait: isPortrait)
        }
    }
        
    // TODO - can we use screen size here to get values?
    private func calculateCols(isPortrait: Bool) {
        if idiom == .pad {
            if (isPortrait == true) {
                cols = 4
            } else {
                cols = 7
            }
        } else {
            if (isPortrait == true) {
                cols = 3
            } else {
                cols = 4
            }
        }
    }
}
