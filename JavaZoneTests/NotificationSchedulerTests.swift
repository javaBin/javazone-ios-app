import XCTest
import UserNotifications
@testable import JavaZone

/// Covers request construction only. Scheduling itself needs a real notification centre
/// and user authorization, neither of which is available in a unit test.
final class NotificationSchedulerTests: XCTestCase {

    private func reminder(start: Date, id: String = "s1") -> NotificationScheduler.Reminder {
        NotificationScheduler.Reminder(sessionId: id, title: "Kotlin in anger", room: "Room 1", start: start)
    }

    func testRequestIsIdentifiedBySessionId() throws {
        let request = try XCTUnwrap(NotificationScheduler.buildRequest(reminder(start: Date(), id: "abc-123")))
        XCTAssertEqual(request.identifier, "abc-123")
    }

    func testRequestCarriesTitleAndRoom() throws {
        let start = Date()
        let request = try XCTUnwrap(NotificationScheduler.buildRequest(reminder(start: start)))
        XCTAssertEqual(request.content.title, "Kotlin in anger")
        XCTAssertTrue(request.content.subtitle.contains("Room 1"))
        XCTAssertTrue(request.content.subtitle.contains(start.asTime()))
    }

    func testTriggerFiresSevenMinutesBeforeStart() throws {
        #if !TESTNOTIFICATIONS
        var components = DateComponents()
        components.year = 2025; components.month = 9; components.day = 3
        components.hour = 10; components.minute = 0; components.second = 0
        let start = try XCTUnwrap(Calendar.current.date(from: components))

        let request = try XCTUnwrap(NotificationScheduler.buildRequest(reminder(start: start)))
        let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)

        XCTAssertEqual(trigger.dateComponents.hour, 9)
        XCTAssertEqual(trigger.dateComponents.minute, 53)
        XCTAssertFalse(trigger.repeats)
        #endif
    }

    func testDisabledWhenSkipNotificationsArgumentPresent() {
        // The UI test target launches with --skip-notifications so screenshots are never
        // interrupted by the permission dialog. A plain unit test run has no such argument.
        XCTAssertEqual(
            NotificationScheduler.isDisabled,
            ProcessInfo.processInfo.arguments.contains("--skip-notifications")
        )
    }
}
