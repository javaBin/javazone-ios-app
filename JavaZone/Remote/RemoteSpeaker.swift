import Foundation

struct RemoteSpeaker: Decodable {
    let name: String?
    let bio: String?
    let avatar: URL?
    let twitter: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case bio
        case avatar
        case twitter
    }
}
