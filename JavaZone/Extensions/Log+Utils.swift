import Foundation
import os

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let coreData = OSLog(subsystem: subsystem, category: "CoreData")
    static let network = OSLog(subsystem: subsystem, category: "Network")
    static let config = OSLog(subsystem: subsystem, category: "Config")
    static let notification = OSLog(subsystem: subsystem, category: "Notifications")
}
