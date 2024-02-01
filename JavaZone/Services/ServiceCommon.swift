import Foundation

enum UpdateStatus: String {
    case success = "Success"
    case fail = "Fail"
    case fatal = "Fatal"
}

struct ServiceError: Error {
    let status: UpdateStatus
    let message: String
    var detail: String?
}
