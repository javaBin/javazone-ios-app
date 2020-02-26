import SwiftUI
import Alamofire
import CoreData
import os

class PartnerService {
    private static func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private static func save(context: NSManagedObjectContext) throws {
        if (context.hasChanges) {
            os_log("Saving changed MOC - Partners", log: .coreData, type: .info)
            try context.save()
        }
    }
    
    static func refresh(onComplete : @escaping (_ status: UpdateStatus, _ msg: String, _ logMsg: String) -> Void) {
        // TODO - add a "last refresh" check
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request = AF.request("https://www.java.no/javazone-ios-app/partners.json")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        os_log("Fetching partners", log: .network, type: .debug)
        
        request.responseDecodable(of: [RemotePartner].self, decoder: decoder) { (response) in
            if let error = response.error {
                os_log("Unable to fetch partners %{public}@", log: .network, type: .error, error.localizedDescription)

                onComplete(.Fail, "Could not download partners, please try again", "")
                
                return
            }
            
            guard let partners = response.value else {
                os_log("Unable to read partners", log: .network, type: .error)

                onComplete(.Fail, "Could not download partners, please try again", "")
                
                return
            }
            
            var contactedPartners: [Partner] = []
            
            os_log("Getting contacted partners", log: .coreData, type: .debug)

            do {
                let request:NSFetchRequest<Partner> = Partner.fetchRequest() as! NSFetchRequest<Partner>

                request.sortDescriptors = []
                request.predicate = NSPredicate(format: "contacted == true")
                
                contactedPartners = try context.fetch(request)
            } catch {
                os_log("Could not get contacted partners %{public}", log: .coreData, type: .error, error.localizedDescription)
                // Go forward - we will lose contacted partners - but may complete
            }
            
            let contacted = contactedPartners
                .compactMap { (partner) -> String? in
                    return partner.url
            }
            
            os_log("Got %{public}d contaced partners", log: .coreData, type: .debug, contacted.count)

            do {
                os_log("Clearing old partners", log: .coreData, type: .debug)

                let result = try context.execute(Partner.clear()) as! NSBatchDeleteResult

                let changes: [AnyHashable: Any] = [
                    NSDeletedObjectsKey: result.result as! [NSManagedObjectID]
                ]
                
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            } catch {
                os_log("Could not clear partners %{public}", log: .coreData, type: .error, error.localizedDescription)
                
                onComplete(.Fatal, "Issue in the data store - please delete and reinstall", "Unable to clear partner data \(error)")
                
                return
            }
            
            var newPartners : [Partner] = []
            
            partners.forEach { (remotePartner) in
                if let url = remotePartner.url {
                    let partner = Partner(context: context)
                    
                    partner.url = url
                    partner.name = remotePartner.name
                    partner.image = remotePartner.image

                    partner.contacted = contacted.contains(url)
                                        
                    newPartners.append(partner)
                }
            }
            
            os_log("Saw %{public}d new partners", log: .network, type: .debug, newPartners.count)

            do {
                try save(context: context)
            } catch {
                os_log("Could not save partners %{public}", log: .coreData, type: .error, error.localizedDescription)

                onComplete(.Fatal, "Issue in the data store - please delete and reinstall", "Unable to save data - partners \(error)")

                return
            }
            
            onComplete(.OK, "", "")
        }
    }
}
