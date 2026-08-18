import XCTest
@testable import JavaZone

final class DateUtilsTest: XCTestCase {

    // MARK: - Helpers

    /// Builds a date from local-time components so tests are timezone-independent.
    private func localDate(year: Int, month: Int, day: Int, hour: Int, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year; components.month = month; components.day = day
        components.hour = hour; components.minute = minute; components.second = 0
        return Calendar.current.date(from: components)!
    }

    // MARK: - asTime

    func testAsTime() {
        let date = localDate(year: 2024, month: 9, day: 4, hour: 9, minute: 20)
        XCTAssertEqual(date.asTime(), "09:20")
    }

    func testAsTimeMidnight() {
        let date = localDate(year: 2024, month: 9, day: 4, hour: 0, minute: 0)
        XCTAssertEqual(date.asTime(), "00:00")
    }

    // MARK: - asDate

    func testAsDate() {
        let date = localDate(year: 2024, month: 9, day: 4, hour: 10)
        XCTAssertEqual(date.asDate(), "04.09.2024")
    }

    // MARK: - diffInSeconds

    func testDiffInSecondsPositive() {
        let earlier = Date()
        let later = earlier.addingTimeInterval(120)
        XCTAssertEqual(earlier.diffInSeconds(date: later), 120)
    }

    func testDiffInSecondsNegative() {
        let now = Date()
        let earlier = now.addingTimeInterval(-60)
        XCTAssertEqual(now.diffInSeconds(date: earlier), -60)
    }

    func testDiffInSecondsSameDate() {
        let date = Date()
        XCTAssertEqual(date.diffInSeconds(date: date), 0)
    }

    // MARK: - Locale independence

    /// asDate() feeds the day filter in SessionsListView, which compares it against plain
    /// strings from the remote config. A non-Gregorian device calendar must not change it.
    func testAsDateUsesGregorianYearAndAsciiDigits() {
        var components = DateComponents()
        components.year = 2024; components.month = 9; components.day = 4; components.hour = 10
        let date = Calendar(identifier: .gregorian).date(from: components)!

        // Gregorian era, not Buddhist (2567) or any other calendar the device may be set to.
        XCTAssertEqual(date.asDate(), "04.09.2024")
        // And Latin digits, not the locale's numbering system.
        XCTAssertTrue(date.asDate().allSatisfy { $0.isASCII })
        XCTAssertTrue(date.asTime().allSatisfy { $0.isASCII })
    }

    // MARK: - forNotification

    func testForNotificationIsSevenMinutesBefore() {
        let sessionStart = localDate(year: 2024, month: 9, day: 4, hour: 10, minute: 0)
        let notification = sessionStart.forNotification()
        let expected = localDate(year: 2024, month: 9, day: 4, hour: 9, minute: 53)
        XCTAssertEqual(notification, expected)
    }
}
