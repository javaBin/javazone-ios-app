import Foundation

extension Date {
    func forNotification() -> Date? {
        // When debug build - set a notification for 15s in future
        #if TESTNOTIFICATIONS
        return Calendar.current.date(byAdding: .second, value: 15, to: Date())
        #else
        return Calendar.current.date(byAdding: .minute, value: -7, to: self)
        #endif
    }

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
    
    func diffInSeconds(date: Date) -> Int {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.second], from: self, to: date)

        return dateComponents.second ?? 0
    }
    
    func diffInSeconds(key: String, defaultDate: Date) -> Int {
        return self.diffInSeconds(date: UserDefaults.standard.object(forKey: key) as? Date ?? defaultDate)
    }
    
    func shouldUpdate(key: String, defaultDate: Date, maxSecs: Int) -> Bool {
        abs(Date().diffInSeconds(key: key, defaultDate: defaultDate)) > maxSecs
    }
    
    func save(key: String) {
        UserDefaults.standard.set(self, forKey: key)
    }
    
    
}
