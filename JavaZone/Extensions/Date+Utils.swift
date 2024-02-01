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

    private func formatString(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    func asTime() -> String {
        return formatString("HH:mm")
    }

    func asDate() -> String {
        return formatString("dd.MM.yyyy")
    }

    func asDateTime() -> String {
        return formatString("HH:mm (dd.MM.yyyy)")
    }

    func asHour() -> String {
        return "\(formatString("HH")):00"
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
