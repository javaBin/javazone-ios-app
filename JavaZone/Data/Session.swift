import Foundation
import CoreData

public class Session: NSManagedObject {
    @NSManaged public var title: String?
    @NSManaged public var abstract: String?
    @NSManaged public var audience: String?
    @NSManaged public var format: String?
    @NSManaged public var length: String?
    @NSManaged public var room: String?
    @NSManaged public var startUtc: Date?
    @NSManaged public var endUtc: Date?
    @NSManaged public var favourite: Bool
    @NSManaged public var sessionId: String?
    @NSManaged public var videoId: String?
    @NSManaged public var section: String?
    @NSManaged public var registerLoc: String?
    @NSManaged public var speakers: NSSet
    @NSManaged public var workshopPrerequisites: String?

    public var speakerArray: [Speaker] {
        let set = speakers as? Set<Speaker> ?? []

        return set.sorted {
            $0.name.val("Unknown") < $1.name.val("Unknown")
        }
    }

    public var lightningTalk: Bool {
        if let fmt = self.format {
            return fmt == "lightning-talk"
        }

        return false
    }

    public var workshop: Bool {
        if let fmt = self.format {
            return fmt == "workshop"
        }

        return false
    }

    public var speakerNames: String {
        return self.speakerArray.map { (speaker) -> String in
            return speaker.name.val("Unknown")
        }.joined(separator: ", ")
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

    func notYetStarted() -> Bool {
        return (startUtc?.diffInSeconds(date: Date()) ?? 0) < 0
    }
}

extension Session {
    public static func getSessions() -> NSFetchRequest<Session> {

        // swiftlint:disable force_cast
        let request: NSFetchRequest<Session> = Session.fetchRequest() as! NSFetchRequest<Session>
        // swiftlint:enable force_cast

        request.sortDescriptors = [
            NSSortDescriptor(key: "startUtc", ascending: true),
            NSSortDescriptor(key: "format", ascending: false),
            NSSortDescriptor(key: "room", ascending: true)
        ]

        request.predicate = NSPredicate(
            format: "format == %@ OR format == %@ OR format == %@",
            "lightning-talk", "presentation", "workshop"
        )

        return request
    }

    static func clear() -> NSBatchDeleteRequest {
        let request = NSBatchDeleteRequest(fetchRequest: Session.fetchRequest())
        request.resultType = .resultTypeObjectIDs
        return request
    }
}
