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
    @NSManaged public var sessionId:String?
    @NSManaged public var speakers:NSSet?
}

extension Session {
    static func getAll() -> NSFetchRequest<Session> {
        let request:NSFetchRequest<Session> = Session.fetchRequest() as! NSFetchRequest<Session>
        
        let sortDescriptor = NSSortDescriptor(key: "startUtc", ascending: true)
        
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    static func getFavourites() -> NSFetchRequest<Session> {
        let request:NSFetchRequest<Session> = Session.fetchRequest() as! NSFetchRequest<Session>

        request.predicate = NSPredicate(format: "favourite == true")
        
        return request
    }
    
    static func clear() -> NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: Session.fetchRequest())
    }

    @objc(addSpeakersObject:)
    @NSManaged public func addSpeaker(_ value: Speaker)

    @objc(removeSpeakersObject:)
    @NSManaged public func removeSpeaker(_ value: Speaker)

    @objc(addSpeakers:)
    @NSManaged public func addSpeakers(_ values: NSSet)

    @objc(removeSpeakers:)
    @NSManaged public func removeSpeakers(_ values: NSSet)

}
