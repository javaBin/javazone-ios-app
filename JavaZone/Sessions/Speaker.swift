import Foundation
import CoreData

public class Speaker:NSManagedObject, Identifiable {
    @NSManaged public var name:String
    @NSManaged public var bio:String?
    @NSManaged public var avatar:String?
    @NSManaged public var twitter:String?
    @NSManaged public var session:Session?
    
    public var id : String {
        return "\(name)-\(session?.id ?? UUID().uuidString)"
    }
}

extension Speaker {
    static func getAll() -> NSFetchRequest<Speaker> {
        let request:NSFetchRequest<Speaker> = Speaker.fetchRequest() as! NSFetchRequest<Speaker>
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    func getAvatarUrl() -> URL? {
        if let avatar = self.avatar {
            return URL(string: avatar)
        }
        
        return nil;
    }
}
