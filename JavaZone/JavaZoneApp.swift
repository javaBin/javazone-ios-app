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

    private static let container: ModelContainer = {
        let schema = Schema([Session.self, SessionBody.self, Speaker.self])
        let config = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            // Schema migration failed — wipe the store so a clean start can happen.
            // All session data is refreshed from the API; only favourites are lost.
            let url = config.url
            for suffix in ["", "-wal", "-shm"] {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
            // swiftlint:disable:next force_try
            return try! ModelContainer(for: schema, configurations: config)
        }
    }()

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
        .modelContainer(Self.container)
    }

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
}
