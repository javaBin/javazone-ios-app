import Foundation

struct RemoteSession: Decodable {
    let sessionId: String?
    let title: String?
    let abstract: String?
    let audience: String?
    let format: String?
    let length: String?
    let room: String?
    let videoId: String?
    let startUtc: Date?
    let endUtc: Date?
    let registerLoc: String?
    let workshopPrerequisites: String?
    let speakers: [RemoteSpeaker]?

    enum CodingKeys: String, CodingKey {
        case sessionId
        case title
        case abstract
        case audience = "intendedAudience"
        case format
        case length
        case room
        case startUtc = "startTimeZulu"
        case endUtc = "endTimeZulu"
        case speakers
        case registerLoc
        case workshopPrerequisites
        case videoId = "video"
    }
}
