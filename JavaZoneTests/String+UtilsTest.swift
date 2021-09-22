import XCTest
@testable import JavaZone

class String_UtilsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSlug() {
        let testString = "This is a test string with some utf-8 characters - æøå - !\"#$%&/()="
        
        let slug = testString.slug()
    
        XCTAssertEqual(slug, "Thisisateststringwithsomeutf-8characters--")
    }
    
    func testContains() {
        let testString = "Hello World"
        
        XCTAssertTrue(testString.contains("ell"))
        XCTAssertFalse(testString.contains("elp"))
    }
    
    func testDeletePrefix() {
        let testString = "Hello World"
        
        XCTAssertEqual("Hello World", testString.deletePrefix("Foo"))
        XCTAssertEqual("World", testString.deletePrefix("Hello "))
    }
}
   
