import SwiftUI
import Alamofire
import os.log

class ConfigService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "ConfigService")

    static func refreshConfig(onComplete: @escaping () -> Void) {
        logger.info("Refreshing config")
        
        let request = AF.request("https://sleepingpill.javazone.no/public/config")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        logger.debug("Fetching config")
        
        request.responseDecodable(of: RemoteConfig.self, decoder: decoder) { (response) in
            if let error = response.error {
                logger.error("Unable to refresh config \(error.localizedDescription, privacy: .public)")
                
                onComplete()
                
                return
            }
            
            guard let config = response.value else {
                logger.error("Unable to fetch config")
                
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
            
            logger.info("Saving config \(newConfig.description, privacy: .public)")
            
            newConfig.saveConfig()
            
            onComplete()
        }
    }
}
