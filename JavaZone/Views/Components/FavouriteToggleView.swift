import SwiftUI
import SwiftData
import UserNotifications
import os.log

struct FavouriteToggleView: View {
    private let logger = Logger(subsystem: Logger.subsystem, category: "FavouriteToggleView")
    var session: Session

    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30.0, height: 30.0)
            .onTapGesture { toggle() }
    }

    private var imageName: String {
        session.favourite
            ? "person.crop.circle.fill.badge.checkmark"
            : "person.crop.circle.badge.plus"
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
                let center = UNUserNotificationCenter.current()
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                guard granted else { return }
                if isFavourite, let date = notificationTrigger {
                    let triggerDate = date.forNotification() ?? date
                    let calComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
                    let components = Calendar.current.dateComponents(calComponents, from: triggerDate)
                    let content = buildNotificationContent(
                        title: notificationTitle,
                        location: notificationLocation,
                        date: date
                    )
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
                    try await center.add(request)
                } else {
                    UNUserNotificationCenter.current()
                        .removePendingNotificationRequests(withIdentifiers: [notificationId])
                }
            } catch {
                logger.error("Notification error: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private func buildNotificationContent(title: String, location: String, date: Date) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = "Your next session starts in \(location) at \(date.asTime())"
        content.sound = .default
        return content
    }
}

#Preview {
    // swiftlint:disable:next force_try
    let container = try! ModelContainer(
        for: Session.self, SessionBody.self, Speaker.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let session = Session(title: "Test", favourite: false, sessionId: "test-1")
    FavouriteToggleView(session: session)
        .modelContainer(container)
}
