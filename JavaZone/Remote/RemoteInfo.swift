import Foundation

struct RemoteInfo: Decodable, Hashable {
    let title: String
    let body: String

    enum CodingKeys: String, CodingKey {
        case title
        case body
    }
}
