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

extension String? {
    func val(_ defVal: String = "") -> String {
        self?.trimmingCharacters(in: .whitespacesAndNewlines) ?? defVal
    }

    func hasVal() -> Bool {
        self?.trimmingCharacters(in: .whitespacesAndNewlines) != nil
    }

    func link() -> URL? {
        if let url = self?.trimmingCharacters(in: .whitespacesAndNewlines) {
            return URL(string: url)
        }

        return nil
    }

    func videoLink() -> URL? {
        if let videoId = self?.trimmingCharacters(in: .whitespacesAndNewlines) {
            return URL(string: "https://vimeo.com/\(videoId)")
        }

        return nil
    }
}
