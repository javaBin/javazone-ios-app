import Foundation

extension String {
    func containsIgnoringCase(_ candidate: String) -> Bool {
        self.range(of: candidate, options: .caseInsensitive) != nil
    }

    func deletePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else {return self}
        return String(self.dropFirst(prefix.count))
    }
}

extension String? {
    func val(_ defVal: String = "") -> String {
        self?.trimmingCharacters(in: .whitespacesAndNewlines) ?? defVal
    }

    func hasVal() -> Bool {
        guard let trimmed = self?.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
        return !trimmed.isEmpty
    }

    func link() -> URL? {
        if let url = self?.trimmingCharacters(in: .whitespacesAndNewlines) {
            return URL(string: url)
        }

        return nil
    }
}
