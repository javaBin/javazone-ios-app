import Combine
import os.log

class PartnerViewModel : ObservableObject {
    let logger = Logger(subsystem: Logger.subsystem, category: "PartnerViewModel")

    @Published var displayPartners : [Partner] = []
    @Published var partners : [Partner] = [] {
        willSet {
            logger.info("Updating partners to \(newValue)")
            displayPartners = newValue.shuffled()
        }
    }
    
    private var cancellable : AnyCancellable?
    
    init(partnerPublisher: AnyPublisher<[Partner], Never> = PartnerStorage.shared.partners.eraseToAnyPublisher()) {
        cancellable = partnerPublisher.sink { partners in
            self.logger.info("Updating partners")
            self.partners = partners
        }
    }
}
