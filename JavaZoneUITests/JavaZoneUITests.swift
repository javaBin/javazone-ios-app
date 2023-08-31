import XCTest

final class JavaZoneUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            XCUIDevice.shared.orientation = .landscapeLeft
        }
    }
    
    override func tearDownWithError() throws {
    }
    
    func pause() {
        sleep(2)
    }
    
    func tapElement(element: XCUIElement) {
        element.tap()
        pause()
    }

    func tapRow(app: XCUIApplication, idx: Int) {
        app.collectionViews.buttons.element(boundBy: idx).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        pause()
    }

    func testScreenshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        pause()

        let tabBar = app.tabBars["Tab Bar"]
        
        tapElement(element: tabBar.buttons["Sessions"])
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            tapRow(app: app, idx: 0)
        }
        
        snapshot("1_SessionList")
        
        if (UIDevice.current.userInterfaceIdiom != .pad) {
            tapRow(app: app, idx: 0)

            snapshot("2_Session")
        }

        tapElement(element: tabBar.buttons["My Schedule"])

        if (UIDevice.current.userInterfaceIdiom == .pad) {
            tapRow(app: app, idx: 1)
        }
        
        snapshot("3_Favourites")

        tapElement(element: tabBar.buttons["Partners"])

        snapshot("4_Partners")
    }
}
