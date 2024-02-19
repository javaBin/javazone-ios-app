import SwiftUI
import Alamofire
import os.log

class ConfigService {
    static func refreshConfig(onComplete: @escaping () -> Void) {
        Logger.networking.info("ConfigService: refreshConfig: Refreshing config")

        let request = AF.request("https://sleepingpill.javazone.no/public/config")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        Logger.networking.debug("ConfigService: refreshConfig: Fetching config")

        request.responseDecodable(of: RemoteConfig.self, decoder: decoder) { (response) in
            if let error = response.error {
                Logger.networking.error("""
ConfigService: refreshConfig: Unable to refresh config \(error.localizedDescription, privacy: .public)
"""
                )

                onComplete()

                return
            }

            guard let config = response.value else {
                Logger.networking.error("ConfigService: refreshConfig: Unable to fetch config")

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
                if confDates.count == 2 {
                    newConfig.dates = [confDates[0], confDates[1], workDate]
                }
            }

            // TODO - get web and ID from config endpoint https://github.com/javaBin/sleepingPillCore/issues/27

            Logger.networking.info("""
ConfigService: refreshConfig: Saving config \(newConfig.description, privacy: .public)
"""
            )

            newConfig.saveConfig()

            onComplete()
        }
    }

    static func loadLocalJsonFile<Model: Decodable>(name: String, onComplete: @escaping (_ items: [Model]) -> Void) {
        Logger.licencing.debug("ConfigService: loadLocalJsonFile: Loading json for \(name, privacy: .public)")

        guard let path = Bundle.main.path(forResource: name, ofType: "json") else {
            Logger.licencing.error("""
ConfigService: loadLocalJsonFile: Did not find json file for \(name, privacy: .public)
"""
            )
            return
        }

        Logger.licencing.debug("ConfigService: loadLocalJsonFile: Loading json from \(path, privacy: .public)")

        let url = URL(fileURLWithPath: path)

        let request = AF.request(url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        Logger.licencing.debug("ConfigService: loadLocalJsonFile: Fetching json for \(name, privacy: .public)")

        request.responseDecodable(of: [Model].self, decoder: decoder) { (response) in
            if let error = response.error {
                Logger.licencing.error("""
ConfigService: loadLocalJsonFile: Unable to fetch \(name, privacy: .public) \
\(error.localizedDescription, privacy: .public)
"""
                )

                onComplete([])

                return
            }

            guard let items = response.value else {
                Logger.licencing.error("ConfigService: loadLocalJsonFile: Unable to read \(name, privacy: .public)")

                onComplete([])

                return
            }

            Logger.licencing.debug("""
ConfigService: loadLocalJsonFile: Loaded \(items.count, privacy: .public) items for \(name, privacy: .public)
"""
            )

            onComplete(items)
        }
    }
}
