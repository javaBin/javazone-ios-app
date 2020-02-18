import Foundation

extension String {
    func contains(_ candidate: String) -> Bool {
        self.range(of: candidate, options: .caseInsensitive) != nil
    }
}
