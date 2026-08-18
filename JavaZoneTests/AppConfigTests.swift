import XCTest
@testable import JavaZone

@MainActor
final class AppConfigTests: XCTestCase {

    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Isolated suite: setUp used to wipe the test host's real "Config" key.
        suiteName = "AppConfigTests-\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        try super.tearDownWithError()
    }

    // MARK: - Default values

    func testDefaultTitle() {
        XCTAssertEqual(AppConfig(defaults: defaults).title, AppConfig.defaultTitle)
    }

    func testDefaultUrl() {
        XCTAssertEqual(AppConfig(defaults: defaults).url, AppConfig.defaultUrl)
    }

    func testDefaultDates() {
        XCTAssertEqual(AppConfig(defaults: defaults).dates, AppConfig.defaultDates)
    }

    func testDefaultWeb() {
        XCTAssertEqual(AppConfig(defaults: defaults).web, AppConfig.defaultWeb)
    }

    // MARK: - apply(remote:) — a complete config is applied

    func testApplyUpdatesTitle() {
        let config = AppConfig(defaults: defaults)
        XCTAssertTrue(config.apply(remote: completeConfig(name: "JavaZone 2025")))
        XCTAssertEqual(config.title, "JavaZone 2025")
    }

    func testApplyUpdatesUrl() {
        let config = AppConfig(defaults: defaults)
        let url = "https://sleepingpill.javazone.no/public/allSessions/javazone_2025"
        XCTAssertTrue(config.apply(remote: completeConfig(conferenceUrl: url)))
        XCTAssertEqual(config.url, url)
    }

    func testApplyUpdatesDatesWithTwoConferenceDaysAndWorkshopDay() {
        let config = AppConfig(defaults: defaults)
        XCTAssertTrue(config.apply(remote: completeConfig(
            workshopDate: "02.09.2025", conferenceDates: ["03.09.2025", "04.09.2025"]
        )))
        XCTAssertEqual(config.dates, ["03.09.2025", "04.09.2025", "02.09.2025"])
    }

    // MARK: - apply(remote:) — an incomplete config is rejected whole
    //
    // Sleeping Pill generates the config, so a missing field means a corrupt download.
    // Half-applying one would persist it over the last known-good values.

    func testApplyEmptyConfigIsRejected() {
        let config = AppConfig(defaults: defaults)
        XCTAssertFalse(config.apply(remote: remoteConfig()))
    }

    func testApplyMissingNameIsRejected() {
        XCTAssertFalse(AppConfig(defaults: defaults).apply(remote: completeConfig(name: nil)))
    }

    func testApplyMissingUrlIsRejected() {
        XCTAssertFalse(AppConfig(defaults: defaults).apply(remote: completeConfig(conferenceUrl: nil)))
    }

    func testApplyMissingWorkshopDateIsRejected() {
        XCTAssertFalse(AppConfig(defaults: defaults).apply(remote: completeConfig(workshopDate: nil)))
    }

    func testApplyWrongNumberOfConferenceDatesIsRejected() {
        XCTAssertFalse(AppConfig(defaults: defaults).apply(remote: completeConfig(conferenceDates: ["03.09.2025"])))
    }

    func testRejectedConfigLeavesEveryFieldUntouched() {
        let config = AppConfig(defaults: defaults)
        XCTAssertTrue(config.apply(remote: completeConfig()))

        XCTAssertFalse(config.apply(remote: remoteConfig(name: "Corrupt")))

        XCTAssertEqual(config.title, "JavaZone 2025")
        XCTAssertEqual(config.url, "https://sleepingpill.javazone.no/public/allSessions/javazone_2025")
        XCTAssertEqual(config.dates, ["03.09.2025", "04.09.2025", "02.09.2025"])
    }

    // MARK: - Helpers

    /// A well-formed payload — every field present, as Sleeping Pill generates it.
    private func completeConfig(
        name: String? = "JavaZone 2025",
        conferenceUrl: String? = "https://sleepingpill.javazone.no/public/allSessions/javazone_2025",
        workshopDate: String? = "02.09.2025",
        conferenceDates: [String]? = ["03.09.2025", "04.09.2025"]
    ) -> RemoteConfig {
        RemoteConfig(
            conferenceName: name,
            conferenceUrl: conferenceUrl,
            workshopDate: workshopDate,
            conferenceDates: conferenceDates
        )
    }

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
