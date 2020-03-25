import Foundation
import os

public class Config : Codable {
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
            os_log("Fetching config - fetch OK", log: .config, type: .info)

            let decoder = JSONDecoder()

            if let config = try? decoder.decode(Config.self, from: config) {
                os_log("Fetching config - decode OK", log: .config, type: .info)

                return config
            }
        }

        os_log("Fetching config - returning default", log: .config, type: .info)

        return Config()
    }
    
    func saveConfig() {
        os_log("Saving config %{public}@", log: .config, type: .info, self.description )

        let encoder = JSONEncoder()
        
        if let encoded = try? encoder.encode(self) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "Config")
            
            Config.sharedConfig = self
        } else {
            os_log("Unable to encode config %{public}@", log: .config, type: .error, self.description )
        }
    }
}

