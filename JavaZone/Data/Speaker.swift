import Foundation
import CoreData

public class Speaker: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var bio: String?
    @NSManaged public var avatar: String?
    @NSManaged public var twitter: String?
    @NSManaged public var session: Session?
}
