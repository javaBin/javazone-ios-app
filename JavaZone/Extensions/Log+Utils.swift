import Foundation
import os.log

extension Logger {
    public static var subsystem = Bundle.main.bundleIdentifier!

    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")

    static let networking = Logger(subsystem: subsystem, category: "networking")

    static let datastore = Logger(subsystem: subsystem, category: "datastore")

    static let preferences = Logger(subsystem: subsystem, category: "preferences")

    static let licencing = Logger(subsystem: subsystem, category: "licencing")

    static let interaction = Logger(subsystem: subsystem, category: "interaction")
}
