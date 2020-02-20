import Foundation
import CoreData

public class Session:NSManagedObject {
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
    @NSManaged public var section:String?
    @NSManaged public var registerLoc:String?
    @NSManaged public var speakers:NSSet
    
    public var wrappedTitle : String {
        return self.title ?? ""
    }
    
    public var wrappedAudience : String {
        return self.audience ?? ""
    }
    
    public var wrappedAbstract : String {
        return self.abstract ?? ""
    }

    public var wrappedRoom : String {
        return self.room ?? ""
    }
    
    public var wrappedSection : String {
        return self.section ?? "??"
    }
    
    public var wrappedFormat : String {
        return self.format ?? ""
    }
    
    public var wrappedRegisterLoc : URL? {
        if let urlString = self.registerLoc {
            if let url = URL(string: urlString) {
                return url
            }
        }
        
        return nil
    }
    
    public var speakerArray : [Speaker] {
        let set = speakers as? Set<Speaker> ?? []

        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }

    public var lightningTalk : Bool {
        if let fmt = self.format {
            return fmt == "lightning-talk"
        }
        
        return false
    }
    
    public var speakerNames : String {
        return self.speakerArray.map { (speaker) -> String in
            return speaker.wrappedName
        }.joined(separator: ", ")
    }

    public var feedbackOpen : Bool {
        // TODO https://github.com/javaBin/javazone-ios-app/issues/8
        return Bool.random();
    }
}

extension Session {
    private func asTime(_ date: Date?) -> String {
        if let date = date {
            return date.asTime()
        }
        
        return "??"
    }
    
    func fromTime() -> String {
        return asTime(startUtc)
    }

    func toTime() -> String {
        return asTime(endUtc)
    }
}

extension Session {
    public static func getSessions() -> NSFetchRequest<Session> {

        let request:NSFetchRequest<Session> = Session.fetchRequest() as! NSFetchRequest<Session>

        request.sortDescriptors = [
            NSSortDescriptor(key: "startUtc", ascending: true),
            NSSortDescriptor(key: "format", ascending: false),
            NSSortDescriptor(key: "room", ascending: true)
        ]

        request.predicate = NSPredicate(format: "format == %@ OR format == %@ OR format == %@", "lightning-talk", "presentation", "workshop")
        
        return request
    }
    
    static func clear() -> NSBatchDeleteRequest {
        let request = NSBatchDeleteRequest(fetchRequest: Session.fetchRequest())
        request.resultType = .resultTypeObjectIDs
        return request
    }
}
