import Foundation

public class Config : Codable {
    public var title:String = defaultTitle
    public var url:String = defaultUrl
    public var dates:[String] = defaultDates
    
    enum CodingKeys: String, CodingKey {
        case title
        case url
        case dates
    }
}

extension Config {
    static let defaultTitle = "JavaZone 2019"
    static let defaultUrl = "https://sleepingpill.javazone.no/public/allSessions/javazone_2019"
    static let defaultDates = ["11.09.2019","12.09.2019","10.09.2019"]
}

extension Config {
    static func getConfig() -> Config {
        let defaults = UserDefaults.standard
        
        if let config = defaults.object(forKey: "Config") as? Data {
            print("Fetching config - decoding OK")
            let decoder = JSONDecoder()
            if let config = try? decoder.decode(Config.self, from: config) {
                print("Returning saved config")
                return config
            }
        }

        print("Returning default config")
        return Config()
    }
    
    func saveConfig() {
        print("Saving config")

        let encoder = JSONEncoder()
        
        if let encoded = try? encoder.encode(self) {
            print("Saving config - encoding OK")
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "Config")
        }
    }
}

