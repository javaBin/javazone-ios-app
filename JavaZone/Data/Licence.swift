import Foundation
import os.log

public struct Copyright: Decodable, Hashable {
    var date: String
    var holder: String
    var contact: String

    var link: URL? {
        return URL(string: self.contact)
    }
}

public struct Licence: Decodable, Hashable {
    var name: String
    var url: String
    var copyright: Copyright
    var licence: [String]

    var link: URL? {
        return URL(string: self.url)
    }
}
