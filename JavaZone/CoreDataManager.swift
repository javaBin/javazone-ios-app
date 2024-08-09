import CoreData
import os.log

struct CoreDataManager {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "JavaZone")

        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                Logger.datastore.error("""
AppDelegate: persistentContainer: Unable to load persistent stores \(error.localizedDescription, privacy: .public)
"""
                )

                // If we have no store - we're unable to do anything useful
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                Logger.datastore.info("AppDelegate: saveContext: Saving context")

                try context.save()
            } catch {
                Logger.datastore.error("""
AppDelegate: saveContext: Saving context failed \(error.localizedDescription, privacy: .public)
"""
                )

                let nserror = error as NSError

                // If we can't save - we're unable to do anything useful
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
