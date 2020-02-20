import Foundation

extension String {
    func contains(_ candidate: String) -> Bool {
        self.range(of: candidate, options: .caseInsensitive) != nil
    }

    func deletePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else {return self}
        return String(self.dropFirst(prefix.count))
    }
}

