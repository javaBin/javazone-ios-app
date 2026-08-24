import Foundation
import UserNotifications
import os.log

struct NotificationScheduler {
    static let logger = Logger(subsystem: Logger.subsystem, category: "NotificationScheduler")

    struct Reminder {
        let sessionId: String
        let title: String
        let room: String
        let start: Date
    }

    /// Skipped in UI test runs
    static var isDisabled: Bool {
        ProcessInfo.processInfo.arguments.contains("--skip-notifications")
    }

    static func requestAuthorization() async -> Bool {
        guard !isDisabled else { return false }
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            logger.error("Authorization failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    static func schedule(_ reminder: Reminder) async {
        guard !isDisabled else { return }
        guard let request = buildRequest(reminder) else { return }
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            logger.error("Could not schedule reminder: \(error.localizedDescription, privacy: .public)")
        }
    }

    static func cancel(sessionId: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [sessionId])
    }

    static func reconcile(favourites: [Reminder]) async {
        guard !isDisabled else { return }
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            logger.debug("Not authorized — skipping reconcile")
            return
        }

        center.removeAllPendingNotificationRequests()

        let now = Date()
        var scheduled = 0
        for reminder in favourites where reminder.start > now {
            guard let request = buildRequest(reminder) else { continue }
            do {
                try await center.add(request)
                scheduled += 1
            } catch {
                logger.error("Could not re-add reminder: \(error.localizedDescription, privacy: .public)")
            }
        }
        logger.debug("Reconciled \(scheduled, privacy: .public) reminders")
    }

    // MARK: - Private helpers

    /// Exposed for tests via @testable — builds the request without touching the notification centre.
    static func buildRequest(_ reminder: Reminder) -> UNNotificationRequest? {
        guard let triggerDate = reminder.start.forNotification() else { return nil }
        let calComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let components = Calendar.current.dateComponents(calComponents, from: triggerDate)

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.subtitle = "Your next session starts in \(reminder.room) at \(reminder.start.asTime())"
        content.sound = .default

        return UNNotificationRequest(
            identifier: reminder.sessionId,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
    }
}
