import Foundation
import SwiftData

@Model
final class Speaker {
    var name: String?
    var bio: String?
    var avatar: String?
    var twitter: String?
    var session: Session?

    init(
        name: String? = nil,
        bio: String? = nil,
        avatar: String? = nil,
        twitter: String? = nil,
        session: Session? = nil
    ) {
        self.name = name
        self.bio = bio
        self.avatar = avatar
        self.twitter = twitter
        self.session = session
    }

    var wrappedName: String { name ?? "Unknown" }

    var wrappedAvatar: URL? { avatar.flatMap { URL(string: $0) } }

    var wrappedBio: String { bio ?? "" }

    var wrappedTwitter: String { twitter ?? "" }
}
