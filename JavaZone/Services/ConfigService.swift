import SwiftUI
import Alamofire
import os

class ConfigService {
    static func refreshConfig(onComplete: @escaping () -> Void) {
        os_log("Refreshing config", log: .network, type: .info)
        
        let request = AF.request("https://sleepingpill.javazone.no/public/config")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        os_log("Fetching config", log: .network, type: .debug)
        
        request.responseDecodable(of: RemoteConfig.self, decoder: decoder) { (response) in
            if let error = response.error {
                os_log("Unable to refresh config %{public}@", log: .network, type: .error, error.localizedDescription)
                
                onComplete()
                
                return
            }
            
            guard let config = response.value else {
                os_log("Unable to fetch config", log: .network, type: .error)
                
                onComplete()
                
                return
            }
            
            #if DEBUG
            let newConfig = Config()
            newConfig.title = Config.defaultTitle
            newConfig.url = Config.defaultUrl
            newConfig.dates = Config.defaultDates
            newConfig.web = Config.defaultWeb
            newConfig.id = Config.defaultId
            #else
            let newConfig = Config()
            newConfig.title = config.conferenceName ?? Config.defaultTitle
            newConfig.url = config.conferenceUrl ?? Config.defaultUrl
            newConfig.dates = Config.defaultDates
            newConfig.web = Config.defaultWeb
            newConfig.id = Config.defaultId
            
            if let confDates = config.conferenceDates, let workDate = config.workshopDate {
                if (confDates.count == 2) {
                    newConfig.dates = [confDates[0], confDates[1], workDate]
                }
            }
            #endif

            // TODO - get web and ID from config endpoint https://github.com/javaBin/sleepingPillCore/issues/27
            
            os_log("Saving config %{public}@", log: .network, type: .info, newConfig.description)
            
            newConfig.saveConfig()
            
            onComplete()
        }
    }
}
