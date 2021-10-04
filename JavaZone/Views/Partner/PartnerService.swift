import SwiftUI
import Alamofire
import CoreData
import os.log

class PartnerService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "PartnerService")
    
    static let partnerStorage = PartnerStorage.shared
    
    static func refresh(onComplete : @escaping (_ status: UpdateStatus, _ msg: String, _ logMsg: String) -> Void) {
        ConfigService.loadLocalJsonFile(name: "partners") { (partners : [RemotePartner]) in
            if (partners.count == 0) {
                logger.error("Unable to fetch partners")
                
                onComplete(.Fail, "Could not download partners, please try again", "")
                
                return
            }
            
            do {
                logger.debug("Clearing old partners")
                
                try partnerStorage.clear()
            } catch {
                logger.error("Could not clear partners \(error.localizedDescription, privacy: .public)")
                
                onComplete(.Fatal, "Issue in the data store - please delete and reinstall", "Unable to clear partner data \(error)")
                
                return
            }
            
            var newPartners : [Partner] = []
            
            partners.forEach { (remotePartner) in
                if let url = remotePartner.url, let name = remotePartner.name {
                    let partner = partnerStorage.add(name: name, partnerUrl: url)
                    
                    newPartners.append(partner)
                }
            }
            
            logger.debug("Saw \(newPartners.count, privacy: .public) new partners")

            do {
                try partnerStorage.save()
            } catch {
                logger.error("Could not save partners \(error.localizedDescription, privacy: .public)")

                onComplete(.Fatal, "Issue in the data store - please delete and reinstall", "Unable to save data - partners \(error)")

                return
            }
            
            Date().save(key: "PartnerDate")
            
            onComplete(.OK, "", "")
        }
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    static func targetUrl(name: String?) -> URL? {
        if let slug = name?.slug() {
            return getDocumentsDirectory().appendingPathComponent(slug).appendingPathExtension("png")
        }
        
        return nil
    }
}
