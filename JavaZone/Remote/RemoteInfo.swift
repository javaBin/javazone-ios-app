import Foundation

struct RemoteInfo: Decodable, Hashable {
    let title: String
    let body: String?
    let infoType: String?

    enum CodingKeys: String, CodingKey {
        case title
        case body
        case infoType
    }
}
