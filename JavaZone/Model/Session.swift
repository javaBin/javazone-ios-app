import Foundation

struct Session: Decodable {
    let sessionId: String?
    let title: String?
    
    enum CodingKeys: String, CodingKey {
        case sessionId
        case title
    }
}
