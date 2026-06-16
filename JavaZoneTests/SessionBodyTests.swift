import XCTest
import SwiftData
@testable import JavaZone

final class SessionBodyTests: XCTestCase {

    // MARK: - wrappedAbstract

    func testWrappedAbstractNilReturnsEmpty() {
        XCTAssertEqual(SessionBody(sessionId: "s1").wrappedAbstract, "")
    }

    func testWrappedAbstractTrimsWhitespace() {
        XCTAssertEqual(
            SessionBody(sessionId: "s1", abstract: "\n  Abstract body\n").wrappedAbstract,
            "Abstract body"
        )
    }

    // MARK: - wrappedAudience

    func testWrappedAudienceNilReturnsEmpty() {
        XCTAssertEqual(SessionBody(sessionId: "s1").wrappedAudience, "")
    }

    func testWrappedAudienceTrimsWhitespace() {
        XCTAssertEqual(
            SessionBody(sessionId: "s1", audience: "  Intermediate  ").wrappedAudience,
            "Intermediate"
        )
    }

    // MARK: - wrappedWorkshopPrerequisites

    func testWrappedWorkshopPrerequisitesNilReturnsEmpty() {
        XCTAssertEqual(SessionBody(sessionId: "s1").wrappedWorkshopPrerequisites, "")
    }

    func testWrappedWorkshopPrerequisitesReturnsValue() {
        XCTAssertEqual(
            SessionBody(sessionId: "s1", workshopPrerequisites: "Basic Swift knowledge").wrappedWorkshopPrerequisites,
            "Basic Swift knowledge"
        )
    }

    // MARK: - speakerArray (requires relationship context)

    @MainActor
    func testSpeakerArraySortedByName() throws {
        let container = try ModelContainer(
            for: Session.self, SessionBody.self, Speaker.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let body = SessionBody(sessionId: "s1")
        context.insert(body)
        context.insert(Speaker(name: "Charlie", body: body))
        context.insert(Speaker(name: "Alice", body: body))
        context.insert(Speaker(name: "Bob", body: body))
        try context.save()

        XCTAssertEqual(body.speakerArray.map(\.wrappedName), ["Alice", "Bob", "Charlie"])
    }
}
