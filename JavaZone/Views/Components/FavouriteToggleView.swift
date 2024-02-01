import SwiftUI
import UserNotifications
import os.log

struct FavouriteToggleView: View {
    let logger = Logger(subsystem: Logger.subsystem, category: "FavouriteToggleView")

    @Binding var favourite: Bool

    var notificationId: String
    var notificationTitle: String
    var notificationLocation: String
    var notificationTrigger: Date?

    var body: some View {
        Image(systemName: imageNameForToggle(favourite)).resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30.0, height: 30.0).onTapGesture {
                self.toggle()
            }
    }

    func toggle() {
        self.favourite.toggle()

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                // We can do notification stuff
                logger.info("Notification OK")

                if self.favourite == true {
                    if let date = self.notificationTrigger {
                        let triggerDate = date.forNotification() ?? date

                        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                         from: triggerDate)

                        let content = buildNotificationContent(title: self.notificationTitle,
                                                               location: self.notificationLocation,
                                                               date: date)

                        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                        let request = UNNotificationRequest(identifier: self.notificationId,
                                                            content: content,
                                                            trigger: trigger)

                        UNUserNotificationCenter.current().add(request)
                    }
                } else {
                    UNUserNotificationCenter.current()
                        .removePendingNotificationRequests(withIdentifiers: [self.notificationId])
                }
            } else if let error = error {
                logger.error("Notification auth error \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    func imageNameForToggle(_ toggle: Bool) -> String {
        return toggle == true ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.badge.plus"
    }

    func buildNotificationContent(title: String, location: String, date: Date) -> UNNotificationContent {
        let content = UNMutableNotificationContent()

        content.title = title
        content.subtitle = "Your next session starts in \(location) at \(date.asTime())"
        content.sound = UNNotificationSound.default

        return content
    }
}

struct FavouriteToggleView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteToggleView(favourite: .constant(false),
                            notificationId: "",
                            notificationTitle: "",
                            notificationLocation: "",
                            notificationTrigger: Date())
    }
}
