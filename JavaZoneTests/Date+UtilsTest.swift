import XCTest
@testable import JavaZone

class DateUtilsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAsTime() {
        let date = Date.init(timeIntervalSince1970: 0)

        let result = date.asTime()

        XCTAssertEqual(result, "01:00")
    }

    func testAsDate() {
        let date = Date.init(timeIntervalSince1970: 0)

        let result = date.asDate()

        XCTAssertEqual(result, "01.01.1970")
    }

    func testAsDateTime() {
        let date = Date.init(timeIntervalSince1970: 0)

        let result = date.asDateTime()

        XCTAssertEqual(result, "01:00 (01.01.1970)")
    }

    func testAsHour() {
        let date = Date.init(timeIntervalSince1970: 30.0 * 60.0)

        let result = date.asHour()

        XCTAssertEqual(result, "01:00")
    }
}
