import XCTest
@testable import JavaZone

final class StringUtilsTest: XCTestCase {

    // MARK: - String.slug

    func testSlug() {
        let result = "This is a test string with some utf-8 characters - æøå - !\"#$%&/()=".slug()
        XCTAssertEqual(result, "Thisisateststringwithsomeutf-8characters--")
    }

    func testSlugEmptyString() {
        XCTAssertEqual("".slug(), "")
    }

    // MARK: - String.contains (case-insensitive)

    func testContainsCaseInsensitive() {
        XCTAssertTrue("Hello World".contains("ell"))
        XCTAssertTrue("Hello World".contains("HELLO"))
        XCTAssertFalse("Hello World".contains("elp"))
    }

    // MARK: - String.deletePrefix

    func testDeletePrefixMatching() {
        XCTAssertEqual("Hello World".deletePrefix("Hello "), "World")
    }

    func testDeletePrefixNotMatching() {
        XCTAssertEqual("Hello World".deletePrefix("Foo"), "Hello World")
    }

    func testDeletePrefixEmpty() {
        XCTAssertEqual("Hello".deletePrefix(""), "Hello")
    }

    // MARK: - String?.val

    func testValNilReturnsEmptyDefault() {
        let optional: String? = nil
        XCTAssertEqual(optional.val(), "")
    }

    func testValNilReturnsCustomDefault() {
        let optional: String? = nil
        XCTAssertEqual(optional.val("fallback"), "fallback")
    }

    func testValTrimsWhitespace() {
        let optional: String? = "  hello  "
        XCTAssertEqual(optional.val(), "hello")
    }

    func testValReturnsValue() {
        let optional: String? = "JavaZone"
        XCTAssertEqual(optional.val(), "JavaZone")
    }

    // MARK: - String?.hasVal

    func testHasValNilReturnsFalse() {
        let optional: String? = nil
        XCTAssertFalse(optional.hasVal())
    }

    func testHasValWhitespaceOnlyReturnsFalse() {
        let optional: String? = "   "
        // whitespace-only trims to nil equivalent — val() returns "" but hasVal checks trimming
        XCTAssertFalse(optional.hasVal())
    }

    func testHasValWithValueReturnsTrue() {
        let optional: String? = "content"
        XCTAssertTrue(optional.hasVal())
    }

    // MARK: - String?.link

    func testLinkNilReturnsNil() {
        let optional: String? = nil
        XCTAssertNil(optional.link())
    }

    func testLinkValidURLReturnsURL() {
        let optional: String? = "https://javazone.no"
        XCTAssertEqual(optional.link(), URL(string: "https://javazone.no"))
    }

    // MARK: - String?.videoLink

    func testVideoLinkNilReturnsNil() {
        let optional: String? = nil
        XCTAssertNil(optional.videoLink())
    }

    func testVideoLinkBuildsVimeoURL() {
        let optional: String? = "12345678"
        XCTAssertEqual(optional.videoLink(), URL(string: "https://vimeo.com/12345678"))
    }
}
