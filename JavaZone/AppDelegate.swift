import UIKit
import CoreData
import os.log
import Flurry_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let logger = Logger(subsystem: Logger.subsystem, category: "AppDelegate")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        
        let sb = FlurrySessionBuilder()
                  .build(logLevel: FlurryLogLevel.all)
                  .build(crashReportingEnabled: true)
                  .build(appVersion: (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String))
                  .build(iapReportingEnabled: true)
        
        Flurry.startSession(apiKey: EnvConfig.flurryApiKey, sessionBuilder: sb)
        Flurry.log(eventName: "Started")
        
        cleanUpOldImages()
        cleanUpOldBadge()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "JavaZone")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                self.logger.error("Unable to load persistent stores \(error.localizedDescription, privacy: .public)")

                // If we have no store - we're unable to do anything useful
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                logger.info("Saving context")
                
                try context.save()
            } catch {
                logger.error("Saving context failed \(error.localizedDescription, privacy: .public)")

                let nserror = error as NSError

                // If we can't save - we're unable to do anything useful
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
        -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let sessionId = response.notification.request.identifier
        
        NotificationCenter.default.post(name: NSNotification.Name("DetailView"), object: sessionId)
        
        completionHandler()
    }
    
    // MARK: - TidyUp
    
    func cleanUpOldBadge() {
        if (Date().shouldUpdate(key: "LastValidBadgeScan", defaultDate: Date(timeIntervalSince1970: 0), maxSecs: 60 * 60 * 24 * 100)) {
            UserDefaults.standard.removeObject(forKey: "CurrentBadge")
        }
    }

    func cleanUpOldImages() {
        let earliest = Date().addingTimeInterval(-10 * 24 * 60 * 60)

        DispatchQueue.global(qos: .background).async {
            guard let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

            do {
                let documents = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                           includingPropertiesForKeys: nil,
                                                                           options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
               
                for document in documents {
                    if document.pathExtension == "png" {
                        let creationDate = try FileManager.default.attributesOfItem(atPath: document.path)[FileAttributeKey.creationDate] as! Date

                        if (creationDate < earliest) {
                            try FileManager.default.removeItem(at: document)
                        }
                    }
                }
            } catch {
                self.logger.error("An error occured cleaning up old image files \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}

