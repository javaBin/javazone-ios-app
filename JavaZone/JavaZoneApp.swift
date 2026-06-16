import SwiftUI
import SwiftData
import UserNotifications
import os.log

@Observable
final class NotificationRouter {
    var sessionId: String?
}

private final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let logger = Logger(subsystem: Logger.subsystem, category: "AppNotificationDelegate")
    var router: NotificationRouter?

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        logger.info("Notification tapped: \(response.notification.request.identifier, privacy: .public)")
        router?.sessionId = response.notification.request.identifier
        completionHandler()
    }
}

@main
struct JavaZoneApp: App {
    @State private var notificationRouter = NotificationRouter()
    @State private var appConfig = AppConfig()
    @State private var sessionsViewModel = SessionsViewModel()
    private let notificationDelegate = AppNotificationDelegate()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(notificationRouter)
                .environment(appConfig)
                .environment(sessionsViewModel)
                .onAppear {
                    notificationDelegate.router = notificationRouter
                }
        }
        .modelContainer(for: [Session.self, Speaker.self])
    }

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
}
