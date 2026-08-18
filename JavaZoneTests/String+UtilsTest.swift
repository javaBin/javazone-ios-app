import XCTest
@testable import JavaZone

final class StringUtilsTest: XCTestCase {

    // MARK: - String.containsIgnoringCase

    func testContainsIgnoringCase() {
        XCTAssertTrue("Hello World".containsIgnoringCase("ell"))
        XCTAssertTrue("Hello World".containsIgnoringCase("HELLO"))
        XCTAssertFalse("Hello World".containsIgnoringCase("elp"))
    }

    /// The stdlib `contains` must keep its case-sensitive meaning — an overload named
    /// `contains` would silently change it for every String in the module.
    func testStdlibContainsStaysCaseSensitive() {
        XCTAssertFalse("Hello World".contains("HELLO"))
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

    // MARK: - String?.link — malformed input must not produce a URL

    /// A space in the path is percent-encoded, but a malformed host or scheme is rejected.
    /// InfoItemView must therefore treat link() as genuinely optional — info.json is
    /// hand-edited, and a typo here used to be force-unwrapped.
    func testLinkMalformedHostReturnsNil() {
        let optional: String? = "http://[javazone.no"
        XCTAssertNil(optional.link())
    }

    func testLinkMalformedSchemeReturnsNil() {
        let optional: String? = "ht tps://javazone.no"
        XCTAssertNil(optional.link())
    }

    func testLinkEmptyReturnsNil() {
        let optional: String? = ""
        XCTAssertNil(optional.link())
    }
}
