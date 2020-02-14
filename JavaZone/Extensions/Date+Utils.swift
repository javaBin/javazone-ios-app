//

import Foundation


extension Date {
    func asTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        return dateFormatter.string(from: self)
    }
}


