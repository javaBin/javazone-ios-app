import Foundation
import os.log

public class Config : Codable {
    static let logger = Logger(subsystem: Logger.subsystem, category: "Config")

    public var title:String = defaultTitle
    public var url:String = defaultUrl
    public var dates:[String] = defaultDates
    public var web:String = defaultWeb
    public var id:String = defaultId
    
    enum CodingKeys: String, CodingKey {
        case title
        case url
        case dates
        case web
        case id
    }
    
    public var description : String {
        "Title: \(title) URL: \(url) Dates: \(dates) Web: \(web) ID: \(id)"
    }
    
    static var sharedConfig = getConfig()
}

extension Config {
    static let defaultTitle = "JavaZone 2019"
    static let defaultUrl = "https://sleepingpill.javazone.no/public/allSessions/javazone_2019"
    static let defaultDates = ["11.09.2019","12.09.2019","10.09.2019"]
    static let defaultWeb = "https://2019.javazone.no/"
    static let defaultId = "ID"
}

extension Config {

    static func getConfig() -> Config {
        let defaults = UserDefaults.standard
        
        if let config = defaults.object(forKey: "Config") as? Data {
            logger.info("Fetching config - fetch OK")

            let decoder = JSONDecoder()

            if let config = try? decoder.decode(Config.self, from: config) {
                logger.info("Fetching config - decode OK")

                return config
            }
        }

        logger.info("Fetching config - returning default")

        return Config()
    }
    
    func saveConfig() {
        Config.logger.info("Saving config \(self.description, privacy: .public)")

        let encoder = JSONEncoder()
        
        if let encoded = try? encoder.encode(self) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "Config")
            
            Config.sharedConfig = self
        } else {
            Config.logger.error("Unable to encode config \(self.description, privacy: .public)")
        }
    }
}

