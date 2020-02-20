//

import Foundation


extension Date {
    func asTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        return dateFormatter.string(from: self)
    }
    
    func asDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        return dateFormatter.string(from: self)
    }
    
    func asDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm (dd.MM.yyyy)"
        
        return dateFormatter.string(from: self)
    }
    
    func asHour() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        
        return "\(dateFormatter.string(from: self)):00"
    }
}
