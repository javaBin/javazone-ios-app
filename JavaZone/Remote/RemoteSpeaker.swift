import Foundation

struct RemoteSpeaker: Decodable {
    let name: String?
    let bio: String?
    let avatar: String?
    let twitter: String?

    enum CodingKeys: String, CodingKey {
        case name
        case bio
        case avatar = "pictureUrl"
        case twitter
    }
}
