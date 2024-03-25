import SwiftUI
import os.log

class ConfigService {
    static func fetch(url: URL) async throws -> RemoteConfig? {
        let (data, _) = try await URLSession.shared.data(from: url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let decodedResponse = try? decoder.decode(RemoteConfig.self, from: data) {
            return decodedResponse
        } else {
            return nil
        }
    }

    static func refreshConfig(onComplete: @escaping () -> Void) {
        Logger.networking.info("ConfigService: refreshConfig: Refreshing config")

        guard let url = URL(string: "https://sleepingpill.javazone.no/public/config") else {
            Logger.networking.warning("Unable to create config URL")

            DispatchQueue.main.async {
                onComplete()
            }

            return
        }

        Task {
            Logger.networking.debug("ConfigService: refreshConfig: Fetching config")

            do {
                let remoteConfig = try await fetch(url: url)

                guard let config = remoteConfig else {
                    Logger.networking.error("ConfigService: refreshConfig: Unable to fetch config")

                    DispatchQueue.main.async {
                        onComplete()
                    }

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

                DispatchQueue.main.async {
                    onComplete()
                }
            } catch {
                Logger.networking.error("""
ConfigService: refreshConfig: Unable to refresh config \(error.localizedDescription, privacy: .public)
""")

                DispatchQueue.main.async {
                    onComplete()
                }
            }
        }
    }
}
