import SwiftUI
import Alamofire
import CoreData
import SVGKit
import os.log

class PartnerService {
    struct TestData {
        static let badge = """
BEGIN:VCARD
VERSION:4.0
FN;CHARSET=UTF-8:Duke JavaZone
N;CHARSET=UTF-8:JavaZone;Duke;;;
TITLE;CHARSET=UTF-8:Mascot
ORG;CHARSET=UTF-8:javaBin
REV:2020-03-02T13:54:27.821Z
END:VCARD
"""
        static let partner = """
{
  "name": "Test Partner 7",
  "code": ""
}
"""
    }
    
    private static func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private static func save(context: NSManagedObjectContext) throws {
        if (context.hasChanges) {
            Logger.coreData.info("Saving changed MOC - Partners")
            try context.save()
        }
    }
    
    static func clearContacted() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let request:NSFetchRequest<Partner> = Partner.fetchRequest() as! NSFetchRequest<Partner>

            request.sortDescriptors = []
            request.predicate = NSPredicate(format: "contacted == true")
        
            let contactedPartners = try context.fetch(request)
            
            contactedPartners.forEach { (partner) in
                partner.contacted = false
            }
            
            try save(context: context)
        } catch {
            Logger.coreData.error("Could not get clear contacted partners \(error.localizedDescription)")
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

//        let request = AF.request("https://www.java.no/javazone-ios-app/partners.json")
        let request = AF.request(url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        Logger.network.debug("Fetching partners")
        
        request.responseDecodable(of: [RemotePartner].self, decoder: decoder) { (response) in
            if let error = response.error {
                Logger.network.error("Unable to fetch partners \(error.localizedDescription)")

                onComplete(.Fail, "Could not download partners, please try again", "")
                
                return
            }
            
            guard let partners = response.value else {
                Logger.network.error("Unable to read partners")

                onComplete(.Fail, "Could not download partners, please try again", "")
                
                return
            }
            
            var contactedPartners: [Partner] = []
            
            Logger.coreData.debug("Getting contacted partners")

            do {
                let request:NSFetchRequest<Partner> = Partner.fetchRequest() as! NSFetchRequest<Partner>

                request.sortDescriptors = []
                request.predicate = NSPredicate(format: "contacted == true")
                
                contactedPartners = try context.fetch(request)
            } catch {
                Logger.coreData.error("Could not get contacted partners \(error.localizedDescription)")
            }
            
            let contacted = contactedPartners
                .compactMap { (partner) -> String? in
                    return partner.url
            }
            
            Logger.coreData.debug("Got \(contacted.count) contaced partners")

            do {
                Logger.coreData.debug("Clearing old partners")

                let result = try context.execute(Partner.clear()) as! NSBatchDeleteResult

                let changes: [AnyHashable: Any] = [
                    NSDeletedObjectsKey: result.result as! [NSManagedObjectID]
                ]
                
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            } catch {
                Logger.coreData.error("Could not clear partners \(error.localizedDescription)")
                
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

                    partner.contacted = contacted.contains(url)
                                        
                    newPartners.append(partner)

                    fetchImage(partner: partner)
                }
            }
            
            Logger.network.debug("Saw \(newPartners.count) new partners")

            do {
                try save(context: context)
            } catch {
                Logger.coreData.error("Could not save partners \(error.localizedDescription)")

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
                    Logger.network.debug("Fetch image - getting as image for \(imageUrl.absoluteString)")
                    
                    let ext = imageUrl.pathExtension

                    if (ext == "svg") {
                        Logger.network.debug("SVG image - for \(imageUrl.absoluteString)")

                        let svgImage = SVGKImage(contentsOf: imageUrl)
                        
                        if let image = svgImage?.uiImage {
                            Logger.network.debug("Fetch image - saving data to \(url.absoluteString)")
                            if let pngData = image.pngData() {
                                try pngData.write(to: url)
                            }
                        } else {
                            Logger.network.debug("Could not get image from SVG - for \(imageUrl.absoluteString)")
                        }
                    } else {
                        Logger.network.debug("Fetch image - fetching data for \(imageUrl.absoluteString)")

                        let data = try Data(contentsOf: imageUrl)

                        if let image = UIImage(data: data), let pngData = image.pngData() {
                            Logger.network.debug("Fetch image - saving data to \(url.absoluteString)")
                            try pngData.write(to: url)
                        }
                    }
                } catch {
                    Logger.network.error("Could not save image from url \(error.localizedDescription), \(imageUrl.absoluteString)")
                }
            }
        }
    }
    
    static func getImageUrl(partner: Partner) -> URL? {
        if let url = targetUrl(name: partner.name) {
            if (FileManager.default.fileExists(atPath: url.path)) {
                Logger.cache.debug("Found cached partner image")

                return url
            }
        }
        
        return partner.wrappedImage
    }
    
    static func contact(partner: ScannedPartner) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let request:NSFetchRequest<Partner> = Partner.fetchRequest() as! NSFetchRequest<Partner>

            request.sortDescriptors = []
            request.predicate = NSPredicate(format: "name == %@", partner.name ?? "")
        
            let match = try context.fetch(request)
            
            match.forEach { (storedPartner) in
                // TODO - check code
                storedPartner.contacted = true
            }
            
            try save(context: context)
        } catch {
            Logger.coreData.error("Could not get contact partner \(error.localizedDescription)")
        }
    }
}
