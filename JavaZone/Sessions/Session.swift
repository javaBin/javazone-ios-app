import Foundation
import CoreData

public class Session:NSManagedObject, Identifiable {
    @NSManaged public var title:String?
    @NSManaged public var abstract:String?
    @NSManaged public var audience:String?
    @NSManaged public var format:String?
    @NSManaged public var length:String?
    @NSManaged public var room:String?
    @NSManaged public var startUtc:Date?
    @NSManaged public var endUtc:Date?
    @NSManaged public var favourite:Bool
    @NSManaged public var sessionId:String
    @NSManaged public var speakers:Set<Speaker>
}

extension Session {
    private static let favouritePredicate = NSPredicate(format: "favourite == true")
    private static let formatPredicate = NSPredicate(format: "format == %@ OR format == %@", "lightning-talk", "presentation")
    
    public func isLightning() -> Bool {
        if let fmt = self.format {
            return fmt == "lightning-talk"
        }
        
        return false
    }
    
    public func speakerNames() -> String {
        self.speakers.map { (speaker) -> String in
            return speaker.name
        }.joined(separator: ", ")
    }
    
    private static func getSessions() -> NSFetchRequest<Session> {
        let request:NSFetchRequest<Session> = Session.fetchRequest() as! NSFetchRequest<Session>
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "startUtc", ascending: true),
            NSSortDescriptor(key: "format", ascending: false),
            NSSortDescriptor(key: "room", ascending: true)
        ]

        return request
    }
    
    static func getAll() -> NSFetchRequest<Session> {
        let request = getSessions()
        
        request.predicate = formatPredicate
        
        return request
    }
    
    static func getFavourites() -> NSFetchRequest<Session> {
        let request = getSessions()

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [favouritePredicate, formatPredicate])
        
        return request
    }
    
    static func clear() -> NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: Session.fetchRequest())
    }
}
