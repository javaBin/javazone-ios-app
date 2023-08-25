import SwiftUI
import Alamofire
import os.log
import Flurry_iOS_SDK

class ConfigService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "ConfigService")

    static func refreshConfig(onComplete: @escaping () -> Void) {
        Flurry.log(eventName: "RefreshConfig", timed: true)

        logger.info("Refreshing config")
        
        let request = AF.request("https://sleepingpill.javazone.no/public/config")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        logger.debug("Fetching config")
        
        request.responseDecodable(of: RemoteConfig.self, decoder: decoder) { (response) in
            if let error = response.error {
                logger.error("Unable to refresh config \(error.localizedDescription, privacy: .public)")
                
                Flurry.log(errorId: "RefreshFailed", message: "Unable to refresh config", error: error)
                Flurry.endTimedEvent(eventName: "RefreshConfig", parameters: nil)

                onComplete()
                
                return
            }
            
            guard let config = response.value else {
                logger.error("Unable to fetch config")
                
                Flurry.log(errorId: "ConfigRefreshFetchFailed", message: "Unable to fetch config", error: nil)
                Flurry.endTimedEvent(eventName: "RefreshConfig", parameters: nil)

                onComplete()
                
                return
            }
            
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

            // TODO - get web and ID from config endpoint https://github.com/javaBin/sleepingPillCore/issues/27
            
            logger.info("Saving config \(newConfig.description, privacy: .public)")
            
            newConfig.saveConfig()
            
            Flurry.endTimedEvent(eventName: "RefreshConfig", parameters: nil)

            onComplete()
        }
    }
    
    static func loadLocalJsonFile<Model: Decodable>(name: String, onComplete : @escaping (_ items: [Model]) -> Void) {
        logger.debug("Loading json for \(name, privacy: .public)")

        guard let path = Bundle.main.path(forResource: name, ofType: "json") else {
            logger.error("Did not find json file for \(name, privacy: .public)")
            return
        }

        logger.debug("Loading json from \(path, privacy: .public)")

        let url = URL(fileURLWithPath: path)

        let request = AF.request(url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    
        logger.debug("Fetching json for \(name, privacy: .public)")
    
        request.responseDecodable(of: [Model].self, decoder: decoder) { (response) in
            if let error = response.error {
                logger.error("Unable to fetch \(name, privacy: .public) \(error.localizedDescription, privacy: .public)")

                onComplete([])
            
                return
            }
        
            guard let items = response.value else {
                logger.error("Unable to read \(name, privacy: .public)")
                
                onComplete([])
            
                return
            }
            
            logger.debug("Loaded \(items.count, privacy: .public) items for \(name, privacy: .public)")
            
            onComplete(items)
        }
    }
}
