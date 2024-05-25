import Foundation
import os.log

public class Config: Codable {
    public var title: String = defaultTitle
    public var url: String = defaultUrl
    public var dates: [String] = defaultDates
    public var web: String = defaultWeb
    public var id: String = defaultId

    enum CodingKeys: String, CodingKey {
        case title
        case url
        case dates
        case web
        case id
    }

    public var description: String {
        "Title: \(title) URL: \(url) Dates: \(dates) Web: \(web) ID: \(id)"
    }

    static var sharedConfig = getConfig()
}

extension Config {
    static let defaultTitle = "JavaZone 2024"
    static let defaultUrl = "https://sleepingpill.javazone.no/public/allSessions/javazone_2024"
    static let defaultDates = ["04.09.2023", "04.09.2023", "03.09.2023"]
    static let defaultWeb = "https://2024.javazone.no/"
    static let defaultId = "ID"
}

extension Config {

    static func getConfig() -> Config {
        let defaults = UserDefaults.standard

        if let config = defaults.object(forKey: "Config") as? Data {
            Logger.preferences.info("Config: getConfig: fetch OK")

            let decoder = JSONDecoder()

            if let config = try? decoder.decode(Config.self, from: config) {
                Logger.preferences.info("Config: getConfig: decode OK")

                return config
            }
        }

        Logger.preferences.info("Config: getConfig: returning default")

        return Config()
    }

    func saveConfig() {
        Logger.preferences.info("Config: saveConfig: Saving config \(self.description, privacy: .public)")

        let encoder = JSONEncoder()

        if let encoded = try? encoder.encode(self) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "Config")

            Config.sharedConfig = self
        } else {
            Logger.preferences.error("""
Config: saveConfig: Unable to encode config \(self.description, privacy: .public)
"""
            )
        }
    }
}
