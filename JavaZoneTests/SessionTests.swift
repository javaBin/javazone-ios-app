import XCTest
import SwiftData
@testable import JavaZone

final class SessionTests: XCTestCase {

    // MARK: - wrappedTitle

    func testWrappedTitleNilReturnsEmpty() {
        XCTAssertEqual(Session().wrappedTitle, "")
    }

    func testWrappedTitleTrimsWhitespace() {
        XCTAssertEqual(Session(title: "  JavaZone Talk  ").wrappedTitle, "JavaZone Talk")
    }

    func testWrappedTitleReturnsValue() {
        XCTAssertEqual(
            Session(title: "Lessons from the Columbia Space Shuttle").wrappedTitle,
            "Lessons from the Columbia Space Shuttle"
        )
    }

    // MARK: - wrappedRoom / wrappedSection

    func testWrappedRoomNilReturnsEmpty() {
        XCTAssertEqual(Session().wrappedRoom, "")
    }

    func testWrappedRoomReturnsValue() {
        XCTAssertEqual(Session(room: "Room 1").wrappedRoom, "Room 1")
    }

    func testWrappedSectionNilReturnsQuestionMarks() {
        XCTAssertEqual(Session().wrappedSection, "??")
    }

    func testWrappedSectionReturnsSlotTime() {
        XCTAssertEqual(Session(section: "09:20").wrappedSection, "09:20")
    }

    // MARK: - format flags

    func testLightningTalkFormat() {
        let session = Session(format: "lightning-talk")
        XCTAssertTrue(session.lightningTalk)
        XCTAssertFalse(session.workshop)
    }

    func testWorkshopFormat() {
        let session = Session(format: "workshop")
        XCTAssertTrue(session.workshop)
        XCTAssertFalse(session.lightningTalk)
    }

    func testPresentationIsNeitherFlag() {
        let session = Session(format: "presentation")
        XCTAssertFalse(session.lightningTalk)
        XCTAssertFalse(session.workshop)
    }

    func testNilFormatIsNeitherFlag() {
        XCTAssertFalse(Session().lightningTalk)
        XCTAssertFalse(Session().workshop)
    }

    // MARK: - wrappedVideo

    func testWrappedVideoNilVideoIdReturnsNil() {
        XCTAssertNil(Session().wrappedVideo)
    }

    func testWrappedVideoBuildsVimeoURL() {
        XCTAssertEqual(
            Session(videoId: "987654321").wrappedVideo,
            URL(string: "https://vimeo.com/987654321")
        )
    }

    // MARK: - wrappedRegisterLoc

    func testWrappedRegisterLocNilReturnsNil() {
        XCTAssertNil(Session().wrappedRegisterLoc)
    }

    func testWrappedRegisterLocBuildsURL() {
        XCTAssertEqual(
            Session(registerLoc: "https://example.com/register").wrappedRegisterLoc,
            URL(string: "https://example.com/register")
        )
    }

    // MARK: - notYetStarted

    func testNotYetStartedFutureSessionReturnsTrue() {
        XCTAssertTrue(Session(startUtc: Date().addingTimeInterval(3600)).notYetStarted())
    }

    func testNotYetStartedPastSessionReturnsFalse() {
        XCTAssertFalse(Session(startUtc: Date().addingTimeInterval(-3600)).notYetStarted())
    }

    func testNotYetStartedNilStartDateReturnsFalse() {
        XCTAssertFalse(Session().notYetStarted())
    }

    // MARK: - speakerNames

    func testSpeakerNamesDefaultsEmpty() {
        XCTAssertEqual(Session().speakerNames, "")
    }

    func testSpeakerNamesReturnsStoredValue() {
        let session = Session()
        session.speakerNames = "Alice, Zara"
        XCTAssertEqual(session.speakerNames, "Alice, Zara")
    }
}
