import XCTest
@testable import JavaZone

/// Uses an isolated UserDefaults suite so the test host's real config is never touched.
@MainActor
final class AppConfigPersistenceTests: XCTestCase {

    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "AppConfigPersistenceTests-\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        try super.tearDownWithError()
    }

    func testRoundTripsThroughUserDefaults() {
        let config = AppConfig(defaults: defaults)
        XCTAssertTrue(config.apply(remote: RemoteConfig(
            conferenceName: "JavaZone 2025",
            conferenceUrl: "https://sleepingpill.javazone.no/public/allSessions/javazone_2025",
            workshopDate: "02.09.2025",
            conferenceDates: ["03.09.2025", "04.09.2025"]
        )))

        let reloaded = AppConfig(defaults: defaults)
        XCTAssertEqual(reloaded.title, "JavaZone 2025")
        XCTAssertEqual(reloaded.url, "https://sleepingpill.javazone.no/public/allSessions/javazone_2025")
        XCTAssertEqual(reloaded.dates, ["03.09.2025", "04.09.2025", "02.09.2025"])
    }

    func testEmptySuiteFallsBackToDefaults() {
        let config = AppConfig(defaults: defaults)
        XCTAssertEqual(config.title, AppConfig.defaultTitle)
        XCTAssertEqual(config.dates, AppConfig.defaultDates)
    }

    // MARK: - A corrupt download must not overwrite a good stored config

    func testRejectedConfigIsNotPersisted() {
        let config = AppConfig(defaults: defaults)
        XCTAssertTrue(config.apply(remote: RemoteConfig(
            conferenceName: "JavaZone 2025",
            conferenceUrl: "https://sleepingpill.javazone.no/public/allSessions/javazone_2025",
            workshopDate: "02.09.2025",
            conferenceDates: ["03.09.2025", "04.09.2025"]
        )))

        // A truncated download: nothing decodes into the optional fields.
        XCTAssertFalse(config.apply(remote: RemoteConfig(
            conferenceName: nil, conferenceUrl: nil, workshopDate: nil, conferenceDates: nil
        )))

        let reloaded = AppConfig(defaults: defaults)
        XCTAssertEqual(reloaded.title, "JavaZone 2025")
        XCTAssertEqual(reloaded.url, "https://sleepingpill.javazone.no/public/allSessions/javazone_2025")
        XCTAssertEqual(reloaded.dates, ["03.09.2025", "04.09.2025", "02.09.2025"])
    }

    /// dates is subscripted directly by the DayPicker, so it must always have three entries.
    func testStoredConfigWithTooFewDatesIsPaddedOnLoad() throws {
        let legacy: [String: Any] = [
            "title": "Old", "url": "", "dates": ["03.09.2025"], "web": "https://javazone.no/"
        ]
        defaults.set(try JSONSerialization.data(withJSONObject: legacy), forKey: AppConfig.storageKey)

        let config = AppConfig(defaults: defaults)
        XCTAssertEqual(config.dates.count, 3)
        XCTAssertEqual(config.dates[0], "03.09.2025")
        XCTAssertEqual(config.dates[2], "")
    }
}
