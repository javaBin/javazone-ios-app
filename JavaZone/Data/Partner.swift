import Foundation
import CoreData

public class Partner:NSManagedObject {
    @NSManaged public var name:String?
    @NSManaged public var url:String?
    @NSManaged public var logoUrl:String?

    public var wrappedName : String {
        return self.name ?? ""
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
    
    public var wrappedLogoUrl : String {
        return self.logoUrl ?? ""
    }
    
    public var wrappedLogo : URL? {
        if let url = self.logoUrl {
            return URL(string: url)
        }
        
        return nil
    }

    public var isSVG: Bool {
        return wrappedLogoUrl.count > 4 && wrappedLogoUrl.suffix(3).description.localizedCaseInsensitiveContains("svg")
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
