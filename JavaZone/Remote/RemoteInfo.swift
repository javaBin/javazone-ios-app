import Foundation

struct RemoteUrl: Decodable, Hashable {
    let title: String
    let url: String
}

struct RemoteInfo: Decodable, Hashable {
    let title: String
    let body: String?
    let infoType: String?
    let url: RemoteUrl?

    enum CodingKeys: String, CodingKey {
        case title
        case body
        case infoType
        case url
    }
}
