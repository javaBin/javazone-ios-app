import SwiftUI
import Alamofire
import os.log

class ConfigService {
    static func refreshConfig(onComplete: @escaping () -> Void) {
        Logger.network.info("Refreshing config")
        
        let request = AF.request("https://sleepingpill.javazone.no/public/config")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        Logger.network.debug("Fetching config")
        
        request.responseDecodable(of: RemoteConfig.self, decoder: decoder) { (response) in
            if let error = response.error {
                Logger.network.error("Unable to refresh config \(error.localizedDescription)")
                
                onComplete()
                
                return
            }
            
            guard let config = response.value else {
                Logger.network.error("Unable to fetch config")
                
                onComplete()
                
                return
            }
            
            #if USE2019
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
            
            Logger.network.info("Saving config \(newConfig.description)")
            
            newConfig.saveConfig()
            
            onComplete()
        }
    }
}
