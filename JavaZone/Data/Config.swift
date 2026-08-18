import Foundation
import os.log

@Observable
@MainActor
final class AppConfig {
    private let logger = Logger(subsystem: Logger.subsystem, category: "AppConfig")

    /// Injectable so tests don't mutate the test host's real defaults.
    @ObservationIgnored private let defaults: UserDefaults

    var title: String = AppConfig.defaultTitle
    var url: String = AppConfig.defaultUrl
    var dates: [String] = AppConfig.defaultDates
    var web: String = AppConfig.defaultWeb
    var partnerUrl: URL = EnvConfig.partnerUrl

    static let defaultTitle = "JavaZone"
    static let defaultUrl = ""
    static let defaultDates = ["", "", ""]
    static let defaultWeb = "https://javazone.no/"

    /// Two conference days plus a workshop day — the DayPicker indexes into these directly.
    static let dayCount = 3

    static let storageKey = "Config"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadFromDefaults()
    }

    private func loadFromDefaults() {
        guard let data = defaults.object(forKey: Self.storageKey) as? Data,
              let stored = try? JSONDecoder().decode(StoredConfig.self, from: data) else {
            logger.info("No stored config, using defaults")
            return
        }
        title = stored.title
        url = stored.url
        dates = Self.normalized(stored.dates)
        web = stored.web
    }

    /// Applies a remote config, or rejects it whole.
    ///
    /// Sleeping Pill generates this payload, so every field is expected to be present — a
    /// partial one means a corrupt download, not a partially-published conference. Applying
    /// it field by field would persist a half-config over known-good values, and the worst
    /// case there is silent: `conferenceUrl` falling back to "" leaves nowhere to fetch
    /// sessions from, and the empty string is then saved for the next launch.
    ///
    /// - Returns: `true` when the config was applied and persisted.
    @discardableResult
    func apply(remote: RemoteConfig) -> Bool {
        guard let conferenceName = remote.conferenceName,
              let conferenceUrl = remote.conferenceUrl,
              let workshopDate = remote.workshopDate,
              let confDates = remote.conferenceDates, confDates.count == 2 else {
            logger.error("Incomplete remote config — keeping the stored one")
            return false
        }

        title = conferenceName
        url = conferenceUrl
        dates = [confDates[0], confDates[1], workshopDate]
        persist()
        return true
    }

    /// Always exactly `dayCount` entries — `dates` is subscripted by the DayPicker index.
    private static func normalized(_ dates: [String]) -> [String] {
        guard dates.count != dayCount else { return dates }
        var result = Array(dates.prefix(dayCount))
        result.append(contentsOf: Array(repeating: "", count: dayCount - result.count))
        return result
    }

    private func persist() {
        let stored = StoredConfig(title: title, url: url, dates: dates, web: web)
        if let encoded = try? JSONEncoder().encode(stored) {
            defaults.set(encoded, forKey: Self.storageKey)
            logger.info("Config saved")
        }
    }

    private struct StoredConfig: Codable {
        var title: String
        var url: String
        var dates: [String]
        var web: String
    }
}
