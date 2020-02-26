import Foundation
import os

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let coreData = OSLog(subsystem: subsystem, category: "CoreData")
    static let network = OSLog(subsystem: subsystem, category: "Network")
    static let config = OSLog(subsystem: subsystem, category: "Config")
    static let scanner = OSLog(subsystem: subsystem, category: "Scanner")
    static let notification = OSLog(subsystem: subsystem, category: "Notifications")
    static let info = OSLog(subsystem: subsystem, category: "Info")
    static let ui = OSLog(subsystem: subsystem, category: "UI")
}
