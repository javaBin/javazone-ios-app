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

    private static let timeFormatter: DateFormatter = {
        let fmt = DateFormatter(); fmt.dateFormat = "HH:mm"; return fmt
    }()
    private static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter(); fmt.dateFormat = "dd.MM.yyyy"; return fmt
    }()
    private static let dateTimeFormatter: DateFormatter = {
        let fmt = DateFormatter(); fmt.dateFormat = "HH:mm (dd.MM.yyyy)"; return fmt
    }()
    private static let hourFormatter: DateFormatter = {
        let fmt = DateFormatter(); fmt.dateFormat = "HH"; return fmt
    }()

    func asTime() -> String { Date.timeFormatter.string(from: self) }
    func asDate() -> String { Date.dateFormatter.string(from: self) }
    func asDateTime() -> String { Date.dateTimeFormatter.string(from: self) }
    func asHour() -> String { "\(Date.hourFormatter.string(from: self)):00" }

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
