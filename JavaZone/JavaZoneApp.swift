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
    private static let logger = Logger(subsystem: Logger.subsystem, category: "JavaZoneApp")

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
            logger.error("Store unusable, wiping: \(error.localizedDescription, privacy: .public)")
            let url = config.url
            for suffix in ["", "-wal", "-shm"] {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
            do {
                return try ModelContainer(for: schema, configurations: config)
            } catch {
                // Last resort: run entirely from memory rather than refusing to launch.
                // Sessions come from the API anyway; only persistence across launches is lost.
                logger.error("Falling back to in-memory store: \(error.localizedDescription, privacy: .public)")
                // swiftlint:disable:next force_try
                return try! ModelContainer(
                    for: schema,
                    configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                )
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(notificationRouter)
                .environment(appConfig)
                .environment(sessionsViewModel)
        }
        .modelContainer(Self.container)
    }

    init() {
        // Wired here rather than in ContentView.onAppear: when the app is cold-launched by a
        // notification tap, didReceive can fire before any view appears.
        notificationDelegate.router = notificationRouter
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
}
