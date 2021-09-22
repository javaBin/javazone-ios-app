import Foundation
import UIKit

extension String {
    func contains(_ candidate: String) -> Bool {
        self.range(of: candidate, options: .caseInsensitive) != nil
    }

    func deletePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else {return self}
        return String(self.dropFirst(prefix.count))
    }
        
    func slug() -> String {
        let allowed = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")
        
        return self.filter { (char) -> Bool in
            return !char.unicodeScalars.contains(where: { !allowed.contains($0)})
        }
    }
}

