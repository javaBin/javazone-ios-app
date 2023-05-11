import Foundation

enum UpdateStatus : String {
    case OK = "OK"
    case Fail = "Fail"
    case Fatal = "Fatal"
}

struct ServiceError : Error {
    let status : UpdateStatus
    let message : String
    var detail : String? = nil
}
