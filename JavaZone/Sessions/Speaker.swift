import Foundation
import CoreData

public class Speaker:NSManagedObject {
    @NSManaged public var name:String?
    @NSManaged public var bio:String?
    @NSManaged public var avatar:String?
    @NSManaged public var twitter:String?
    @NSManaged public var session:Session?
    
    public var wrappedName : String {
        name ?? "Unknown"
    }
    
    public var wrappedAvatar: URL? {
        if let avatar = self.avatar {
            return URL(string: avatar)
        }
        
        return nil;
    }
}
