import Foundation

struct ScannedPartner: Decodable, Hashable {
    let name: String?
    let code: String?

    enum CodingKeys: String, CodingKey {
        case name
        case code
    }
}
