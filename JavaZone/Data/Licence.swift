import Foundation
import os.log

public struct Licence : Decodable, Hashable {
    var name: String
    var url: String
    var licence: [String]
    
    var link : URL? {
        return URL(string:self.url)
    }
}
