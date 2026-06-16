import SwiftUI
import SwiftData
import UserNotifications
import os.log

struct FavouriteToggleView: View {
    private let logger = Logger(subsystem: Logger.subsystem, category: "FavouriteToggleView")
    var session: Session

    var body: some View {
        Image(systemName: session.favourite ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.badge.plus")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30.0, height: 30.0)
            .onTapGesture {
                toggle()
            }
    }

    private func toggle() {
        session.favourite.toggle()
        let isFavourite = session.favourite
        let notificationId = session.sessionId ?? UUID().uuidString
        let notificationTitle = session.wrappedTitle
        let notificationLocation = session.wrappedRoom
        let notificationTrigger = session.startUtc

        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                guard granted else { return }
                if isFavourite, let date = notificationTrigger {
                    let triggerDate = date.forNotification() ?? date
                    let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
                    let content = UNMutableNotificationContent()
                    content.title = notificationTitle
                    content.subtitle = "Your next session starts in \(notificationLocation) at \(date.asTime())"
                    content.sound = .default
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
                    try await UNUserNotificationCenter.current().add(request)
                } else {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
                }
            } catch {
                logger.error("Notification error: \(error.localizedDescription, privacy: .public)")
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

#Preview {
    let container = try! ModelContainer(for: Session.self, Speaker.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let session = Session(title: "Test", favourite: false, sessionId: "test-1")
    FavouriteToggleView(session: session)
        .modelContainer(container)
}
