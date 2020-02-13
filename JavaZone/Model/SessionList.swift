import Foundation

struct SessionList: Decodable {
    let sessions: [Session]
    
    enum CodingKeys: String, CodingKey {
      case sessions
    }
}
