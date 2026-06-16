import Foundation
import SwiftData

@Model
final class SessionBody {
    var sessionId: String = ""
    var abstract: String?
    var audience: String?
    var workshopPrerequisites: String?

    @Relationship(deleteRule: .cascade, inverse: \Speaker.body)
    var speakers: [Speaker]?

    init(
        sessionId: String,
        abstract: String? = nil,
        audience: String? = nil,
        workshopPrerequisites: String? = nil
    ) {
        self.sessionId = sessionId
        self.abstract = abstract
        self.audience = audience
        self.workshopPrerequisites = workshopPrerequisites
    }

    var wrappedAbstract: String { abstract?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
    var wrappedAudience: String { audience?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
    var wrappedWorkshopPrerequisites: String { workshopPrerequisites ?? "" }

    var speakerArray: [Speaker] {
        (speakers ?? []).sorted { $0.wrappedName < $1.wrappedName }
    }
}
