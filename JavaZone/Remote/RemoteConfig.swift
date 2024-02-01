import Foundation

struct RemoteConfig: Decodable {
    let conferenceName: String?
    let conferenceUrl: String?
    let workshopDate: String?
    let conferenceDates: [String]?

    enum CodingKeys: String, CodingKey {
        case conferenceName
        case conferenceUrl
        case workshopDate
        case conferenceDates
    }
}
