import Foundation
import os.log

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let coreData = Logger(subsystem: subsystem, category: "CoreData")
    static let network = Logger(subsystem: subsystem, category: "Network")
    static let config = Logger(subsystem: subsystem, category: "Config")
    static let notification = Logger(subsystem: subsystem, category: "Notifications")
    static let info = Logger(subsystem: subsystem, category: "Info")
    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let cache = Logger(subsystem: subsystem, category: "Cache")
}
