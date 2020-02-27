import Foundation
import CoreData

public class Partner:NSManagedObject {
    @NSManaged public var name:String?
    @NSManaged public var image:String?
    @NSManaged public var url:String?
    @NSManaged public var contacted:Bool

    public var wrappedName : String {
        return self.name ?? ""
    }

    public var wrappedImage : URL? {
        if let image = self.image {
            return URL(string:image)
        }
        
        return nil
    }

    public var wrappedUrl : String {
        return self.url ?? ""
    }
    
    public var wrappedSite : URL? {
        if let url = self.url {
            return URL(string: url)
        }
        
        return nil
    }
}

extension Partner {
    public static func getPartners() -> NSFetchRequest<Partner> {

        let request:NSFetchRequest<Partner> = Partner.fetchRequest() as! NSFetchRequest<Partner>

        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        return request
    }
    
    static func clear() -> NSBatchDeleteRequest {
        let request = NSBatchDeleteRequest(fetchRequest: Partner.fetchRequest())
        request.resultType = .resultTypeObjectIDs
        return request
    }
}
