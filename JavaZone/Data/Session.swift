import Foundation
import SwiftData

@Model
final class Session {
    var title: String?
    var abstract: String?
    var audience: String?
    var format: String?
    var length: String?
    var room: String?
    var startUtc: Date?
    var endUtc: Date?
    var favourite: Bool = false
    var sessionId: String?
    var videoId: String?
    var section: String?
    var registerLoc: String?
    var workshopPrerequisites: String?

    @Relationship(deleteRule: .cascade, inverse: \Speaker.session)
    var speakers: [Speaker] = []

    init(
        title: String? = nil,
        abstract: String? = nil,
        audience: String? = nil,
        format: String? = nil,
        length: String? = nil,
        room: String? = nil,
        startUtc: Date? = nil,
        endUtc: Date? = nil,
        favourite: Bool = false,
        sessionId: String? = nil,
        videoId: String? = nil,
        section: String? = nil,
        registerLoc: String? = nil,
        workshopPrerequisites: String? = nil
    ) {
        self.title = title
        self.abstract = abstract
        self.audience = audience
        self.format = format
        self.length = length
        self.room = room
        self.startUtc = startUtc
        self.endUtc = endUtc
        self.favourite = favourite
        self.sessionId = sessionId
        self.videoId = videoId
        self.section = section
        self.registerLoc = registerLoc
        self.workshopPrerequisites = workshopPrerequisites
    }

    var wrappedTitle: String {
        title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    var wrappedAudience: String {
        audience?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    var wrappedAbstract: String {
        abstract?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    var wrappedRoom: String { room ?? "" }

    var wrappedSection: String { section ?? "??" }

    var wrappedFormat: String { format ?? "" }

    var wrappedVideo: URL? {
        videoId.flatMap { URL(string: "https://vimeo.com/\($0)") }
    }

    var wrappedRegisterLoc: URL? {
        registerLoc.flatMap { URL(string: $0) }
    }

    var speakerNames: String = ""

    var speakerArray: [Speaker] {
        speakers.sorted { $0.wrappedName < $1.wrappedName }
    }

    var lightningTalk: Bool { format == "lightning-talk" }

    var workshop: Bool { format == "workshop" }

    var wrappedWorkshopPrerequisites: String {
        workshopPrerequisites ?? ""
    }

    func fromTime() -> String { startUtc?.asTime() ?? "??" }

    func toTime() -> String { endUtc?.asTime() ?? "??" }

    func notYetStarted() -> Bool {
        (startUtc?.diffInSeconds(date: Date()) ?? 0) < 0
    }
}

extension Session: Hashable {
    static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.persistentModelID == rhs.persistentModelID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(persistentModelID)
    }
}
