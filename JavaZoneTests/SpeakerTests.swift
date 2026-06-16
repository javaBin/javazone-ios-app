import XCTest
@testable import JavaZone

final class SpeakerTests: XCTestCase {

    // MARK: - wrappedName

    func testWrappedNameNilReturnsUnknown() {
        XCTAssertEqual(Speaker().wrappedName, "Unknown")
    }

    func testWrappedNameReturnsValue() {
        XCTAssertEqual(Speaker(name: "Jane Doe").wrappedName, "Jane Doe")
    }

    // MARK: - wrappedBio

    func testWrappedBioNilReturnsEmpty() {
        XCTAssertEqual(Speaker().wrappedBio, "")
    }

    func testWrappedBioReturnsValue() {
        XCTAssertEqual(Speaker(bio: "Conference speaker").wrappedBio, "Conference speaker")
    }

    // MARK: - wrappedTwitter

    func testWrappedTwitterNilReturnsEmpty() {
        XCTAssertEqual(Speaker().wrappedTwitter, "")
    }

    func testWrappedTwitterReturnsHandle() {
        XCTAssertEqual(Speaker(twitter: "javazone").wrappedTwitter, "javazone")
    }

    // MARK: - wrappedAvatar

    func testWrappedAvatarNilReturnsNil() {
        XCTAssertNil(Speaker().wrappedAvatar)
    }

    func testWrappedAvatarBuildsURL() {
        let speaker = Speaker(avatar: "https://example.com/photo.jpg")
        XCTAssertEqual(speaker.wrappedAvatar, URL(string: "https://example.com/photo.jpg"))
    }
}
