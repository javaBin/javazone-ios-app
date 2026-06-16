import Foundation
import os.log

@Observable
@MainActor
final class AppConfig {
    private let logger = Logger(subsystem: Logger.subsystem, category: "AppConfig")

    var title: String = AppConfig.defaultTitle
    var url: String = AppConfig.defaultUrl
    var dates: [String] = AppConfig.defaultDates
    var web: String = AppConfig.defaultWeb
    var id: String = AppConfig.defaultId
    var partnerUrl: URL = EnvConfig.partnerUrl

    static let defaultTitle = "JavaZone 2024"
    static let defaultUrl = "https://sleepingpill.javazone.no/public/allSessions/javazone_2024"
    static let defaultDates = ["04.09.2024", "05.09.2024", "04.09.2024"]
    static let defaultWeb = "https://2024.javazone.no/"
    static let defaultId = "ID"

    init() {
        loadFromDefaults()
    }

    private func loadFromDefaults() {
        guard let data = UserDefaults.standard.object(forKey: "Config") as? Data,
              let stored = try? JSONDecoder().decode(StoredConfig.self, from: data) else {
            logger.info("No stored config, using defaults")
            return
        }
        title = stored.title
        url = stored.url
        dates = stored.dates
        web = stored.web
        id = stored.id
    }

    func apply(remote: RemoteConfig) {
        title = remote.conferenceName ?? Self.defaultTitle
        url = remote.conferenceUrl ?? Self.defaultUrl
        if let confDates = remote.conferenceDates, let workDate = remote.workshopDate, confDates.count == 2 {
            dates = [confDates[0], confDates[1], workDate]
        }
        persist()
    }

    private func persist() {
        let stored = StoredConfig(title: title, url: url, dates: dates, web: web, id: id)
        if let encoded = try? JSONEncoder().encode(stored) {
            UserDefaults.standard.set(encoded, forKey: "Config")
            logger.info("Config saved")
        }
    }

    private struct StoredConfig: Codable {
        var title: String
        var url: String
        var dates: [String]
        var web: String
        var id: String
    }
}
