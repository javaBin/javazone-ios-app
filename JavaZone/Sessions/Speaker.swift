import Foundation
import CoreData

public class Speaker:NSManagedObject, Identifiable {
    @NSManaged public var name:String
    @NSManaged public var bio:String?
    @NSManaged public var avatar:URL?
    @NSManaged public var twitter:String?
    @NSManaged public var session:Session?
}

extension Speaker {
    public override var description: String {
        return self.name
    }
    
    static func getAll() -> NSFetchRequest<Speaker> {
        let request:NSFetchRequest<Speaker> = Speaker.fetchRequest() as! NSFetchRequest<Speaker>
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
}
