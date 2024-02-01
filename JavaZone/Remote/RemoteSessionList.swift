import Foundation

struct RemoteSessionList: Decodable {
    let sessions: [RemoteSession]

    enum CodingKeys: String, CodingKey {
      case sessions
    }
}
