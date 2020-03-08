import XCTest
@testable import JavaZone

class HashServiceTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func testHash() {
        let hash = HashService.hash(salt: "12345", value: "JavaZone")
        
        XCTAssertEqual(hash, "67f9ae3824f6ba51dce9119c2897e542f63eaa4a332c019444c369c31f4b3c83a2e31b1346007a5401b2537e126dfb83383b355054be48a6cfb18f8a9bddbbab")
    }
}
