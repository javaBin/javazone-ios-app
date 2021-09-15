import SwiftUI
import Alamofire
import CoreData
import SVGKit
import os.log

class PartnerService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "PartnerService")

    private static func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private static func save(context: NSManagedObjectContext) throws {
        if (context.hasChanges) {
            logger.info("Saving changed MOC - Partners")
            try context.save()
        }
    }
    
    static func refresh(force: Bool, onComplete : @escaping (_ status: UpdateStatus, _ msg: String, _ logMsg: String) -> Void) {
        if (force != true && !Date().shouldUpdate(key: "PartnerDate", defaultDate: Date(timeIntervalSince1970: 0), maxSecs: 60 * 60 * 24 * 30)) {
            onComplete(.OK, "", "")
            return
        }

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        guard let path = Bundle.main.path(forResource: "partners", ofType: "json") else { return }

        let url = URL(fileURLWithPath: path)

        let request = AF.request(url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        logger.debug("Fetching partners")
        
        request.responseDecodable(of: [RemotePartner].self, decoder: decoder) { (response) in
            if let error = response.error {
                logger.error("Unable to fetch partners \(error.localizedDescription, privacy: .public)")

                onComplete(.Fail, "Could not download partners, please try again", "")
                
                return
            }
            
            guard let partners = response.value else {
                logger.error("Unable to read partners")

                onComplete(.Fail, "Could not download partners, please try again", "")
                
                return
            }
            
            do {
                logger.debug("Clearing old partners")

                let result = try context.execute(Partner.clear()) as! NSBatchDeleteResult

                let changes: [AnyHashable: Any] = [
                    NSDeletedObjectsKey: result.result as! [NSManagedObjectID]
                ]
                
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            } catch {
                logger.error("Could not clear partners \(error.localizedDescription, privacy: .public)")
                
                onComplete(.Fatal, "Issue in the data store - please delete and reinstall", "Unable to clear partner data \(error)")
                
                return
            }
            
            var newPartners : [Partner] = []
            
            partners.forEach { (remotePartner) in
                if let url = remotePartner.url, let name = remotePartner.name, let image = remotePartner.image {
                    let partner = Partner(context: context)
                    
                    partner.url = url
                    partner.name = name
                    partner.image = image

                    newPartners.append(partner)

                    fetchImage(partner: partner)
                }
            }
            
            logger.debug("Saw \(newPartners.count, privacy: .public) new partners")

            do {
                try save(context: context)
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
    
    static func fetchImage(partner: Partner) {
        if let url = targetUrl(name: partner.name), let imageUrl = partner.wrappedImage {
            DispatchQueue.global(qos: .background).async {
                do {
                    logger.debug("Fetch image - getting as image for \(imageUrl.absoluteString, privacy: .public)")
                    
                    let ext = imageUrl.pathExtension

                    if (ext == "svg") {
                        logger.debug("SVG image - for \(imageUrl.absoluteString, privacy: .public)")

                        let svgImage = SVGKImage(contentsOf: imageUrl)
                        
                        if let image = svgImage?.uiImage {
                            logger.debug("Fetch image - saving data to \(url.absoluteString, privacy: .public)")
                            if let pngData = image.pngData() {
                                try pngData.write(to: url)
                            }
                        } else {
                            logger.debug("Could not get image from SVG - for \(imageUrl.absoluteString, privacy: .public)")
                        }
                    } else {
                        logger.debug("Fetch image - fetching data for \(imageUrl.absoluteString, privacy: .public)")

                        let data = try Data(contentsOf: imageUrl)

                        if let image = UIImage(data: data), let pngData = image.pngData() {
                            logger.debug("Fetch image - saving data to \(url.absoluteString, privacy: .public)")
                            try pngData.write(to: url)
                        }
                    }
                } catch {
                    logger.error("Could not save image from url \(error.localizedDescription, privacy: .public), \(imageUrl.absoluteString, privacy: .public)")
                }
            }
        }
    }
    
    static func getImageUrl(partner: Partner) -> URL? {
        if let url = targetUrl(name: partner.name) {
            if (FileManager.default.fileExists(atPath: url.path)) {
                logger.debug("Found cached partner image")

                return url
            }
        }
        
        return partner.wrappedImage
    }
}
