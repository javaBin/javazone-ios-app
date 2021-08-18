import SwiftUI
import Alamofire
import CoreData
import SVGKit
import os

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
            os_log("Saving changed MOC - Partners", log: .coreData, type: .info)
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
           os_log("Could not get clear contacted partners %{public}@", log: .coreData, type: .error, error.localizedDescription)
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
                os_log("Could not get contacted partners %{public}@", log: .coreData, type: .error, error.localizedDescription)
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
                os_log("Could not clear partners %{public}@", log: .coreData, type: .error, error.localizedDescription)
                
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
            
            os_log("Saw %{public}d new partners", log: .network, type: .debug, newPartners.count)

            do {
                try save(context: context)
            } catch {
                os_log("Could not save partners %{public}@", log: .coreData, type: .error, error.localizedDescription)

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
                    os_log("Fetch image - getting as image for %{public}@", log: .network, type: .debug, imageUrl.absoluteString)
                    
                    let ext = imageUrl.pathExtension

                    if (ext == "svg") {
                        os_log("SVG image - for %{public}@", log: .network, type: .debug, imageUrl.absoluteString)

                        let svgImage = SVGKImage(contentsOf: imageUrl)
                        
                        if let image = svgImage?.uiImage {
                            os_log("Fetch image - saving data to %{public}@", log: .network, type: .debug, url.absoluteString)
                            if let pngData = image.pngData() {
                                try pngData.write(to: url)
                            }
                        } else {
                            os_log("Could not get image from SVG - for %{public}@", log: .network, type: .debug, imageUrl.absoluteString)
                        }
                    } else {
                        os_log("Fetch image - fetching data for %{public}@", log: .network, type: .debug, imageUrl.absoluteString)

                        let data = try Data(contentsOf: imageUrl)

                        if let image = UIImage(data: data), let pngData = image.pngData() {
                            os_log("Fetch image - saving data to %{public}@", log: .network, type: .debug, url.absoluteString)
                            try pngData.write(to: url)
                        }
                    }
                } catch {
                    os_log("Could not save image from url %{public}@", log: .network, type: .error, error.localizedDescription, imageUrl.absoluteString)
                }
            }
        }
    }
    
    static func getImageUrl(partner: Partner) -> URL? {
        if let url = targetUrl(name: partner.name) {
            if (FileManager.default.fileExists(atPath: url.path)) {
                os_log("Found cached partner image", type: .debug)

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
           os_log("Could not get contact partner %{public}@", log: .coreData, type: .error, error.localizedDescription)
        }
    }
}
