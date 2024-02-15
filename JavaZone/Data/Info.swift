import Foundation
import os.log

public struct InfoItem: Hashable {
    var title: String
    var body: String?
    var infoType: String?
    var urlTitle: String?
    var url: String?

    var isShort: Bool {
        return body == nil
    }

    var isUrgent: Bool {
        return (infoType ?? "") == "urgent"
    }
}
