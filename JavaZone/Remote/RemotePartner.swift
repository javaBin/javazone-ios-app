import Foundation

struct RemotePartner: Decodable, Hashable {
    let name: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case name
        case url = "homepageUrl"
    }
}
