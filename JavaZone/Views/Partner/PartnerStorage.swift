import Foundation
import Combine
import CoreData
import UIKit
import os.log

class PartnerStorage : NSObject, ObservableObject {
    let logger = Logger(subsystem: Logger.subsystem, category: "PartnerStorage")

    var partners = CurrentValueSubject<[Partner], Never>([])
    private let partnerFetchController : NSFetchedResultsController<Partner>
    private let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static let shared : PartnerStorage = PartnerStorage()
    
    private override init() {
        partnerFetchController = NSFetchedResultsController(
        fetchRequest: Partner.getPartners(),
        managedObjectContext: moc,
        sectionNameKeyPath: nil,
        cacheName: nil)
        
        super.init()
        
        partnerFetchController.delegate = self
        
        do {
            logger.info("Initial partner fetch")
            try partnerFetchController.performFetch()
            partners.value = partnerFetchController.fetchedObjects ?? []
        } catch {
            logger.error("Could not fetch partners \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func add(name: String, partnerUrl: String, logoUrl: String) -> Partner {
        let partner = Partner(context: moc)
        
        partner.name = name
        partner.url = partnerUrl
        partner.logoUrl = logoUrl
        
        return partner
    }

    func clear() throws {
        let result = try moc.execute(Partner.clear()) as! NSBatchDeleteResult

        let changes: [AnyHashable: Any] = [
            NSDeletedObjectsKey: result.result as! [NSManagedObjectID]
        ]
        
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [moc])
    }
    
    func save() throws {
        if (moc.hasChanges) {
            logger.info("Saving changed MOC - Partners")
            try moc.save()
        }
    }
}

extension PartnerStorage : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let partners = controller.fetchedObjects as? [Partner] else { return }
        logger.info("Partner list updated - reloading")
        self.partners.value = partners
    }
}
