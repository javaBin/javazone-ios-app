import XCTest
@testable import JavaZone

@MainActor
final class AppConfigTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "Config")
    }

    // MARK: - Default values

    func testDefaultTitle() {
        XCTAssertEqual(AppConfig().title, AppConfig.defaultTitle)
    }

    func testDefaultUrl() {
        XCTAssertEqual(AppConfig().url, AppConfig.defaultUrl)
    }

    func testDefaultDates() {
        XCTAssertEqual(AppConfig().dates, AppConfig.defaultDates)
    }

    func testDefaultWeb() {
        XCTAssertEqual(AppConfig().web, AppConfig.defaultWeb)
    }

    // MARK: - apply(remote:) — field updates

    func testApplyUpdatesTitle() {
        let config = AppConfig()
        config.apply(remote: remoteConfig(name: "JavaZone 2025"))
        XCTAssertEqual(config.title, "JavaZone 2025")
    }

    func testApplyUpdatesUrl() {
        let config = AppConfig()
        let url = "https://sleepingpill.javazone.no/public/allSessions/javazone_2025"
        config.apply(remote: remoteConfig(conferenceUrl: url))
        XCTAssertEqual(config.url, url)
    }

    func testApplyUpdatesDatesWithTwoConferenceDaysAndWorkshopDay() {
        let config = AppConfig()
        config.apply(remote: remoteConfig(workshopDate: "03.09.2025", conferenceDates: ["03.09.2025", "04.09.2025"]))
        XCTAssertEqual(config.dates, ["03.09.2025", "04.09.2025", "03.09.2025"])
    }

    // MARK: - apply(remote:) — nil fields keep existing values

    func testApplyNilNameKeepsDefault() {
        let config = AppConfig()
        config.apply(remote: remoteConfig())
        XCTAssertEqual(config.title, AppConfig.defaultTitle)
    }

    func testApplyNilUrlKeepsDefault() {
        let config = AppConfig()
        config.apply(remote: remoteConfig())
        XCTAssertEqual(config.url, AppConfig.defaultUrl)
    }

    func testApplyIncompleteDatesKeepsExisting() {
        // Only one conference date — condition requires exactly two
        let config = AppConfig()
        config.apply(remote: remoteConfig(workshopDate: "03.09.2025", conferenceDates: ["03.09.2025"]))
        XCTAssertEqual(config.dates, AppConfig.defaultDates)
    }

    func testApplyMissingWorkshopDateKeepsDates() {
        let config = AppConfig()
        config.apply(remote: remoteConfig(workshopDate: nil, conferenceDates: ["03.09.2025", "04.09.2025"]))
        XCTAssertEqual(config.dates, AppConfig.defaultDates)
    }

    // MARK: - Helpers

    private func remoteConfig(
        name: String? = nil,
        conferenceUrl: String? = nil,
        workshopDate: String? = nil,
        conferenceDates: [String]? = nil
    ) -> RemoteConfig {
        RemoteConfig(
            conferenceName: name,
            conferenceUrl: conferenceUrl,
            workshopDate: workshopDate,
            conferenceDates: conferenceDates
        )
    }
}
