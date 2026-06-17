import XCTest

final class JavaZoneUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false

        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeLeft
        } else {
            XCUIDevice.shared.orientation = .portrait
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
        app
            .collectionViews
            .buttons
            .element(boundBy: idx)
            .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .tap()
        pause()
    }

    @MainActor
    func testScreenshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        pause()

        // On iPad iOS 26, TabView renders as a _UIFloatingTabBar whose items are
        // _UIFloatingTabBarItemCell. XCUI subscript notation ("Sessions") matches by
        // accessibility identifier, but tab items only have a label — not an identifier.
        // Use a label predicate to find them correctly.
        func tapTab(_ name: String) {
            let bar = app.tabBars["Tab Bar"]
            if bar.exists {
                tapElement(element: bar.buttons[name])
            } else {
                // .cell and .button type queries fail on iOS 26 FloatingTabBar due to
                // XCUI type-mismatch. Using .any bypasses the type filter entirely.
                let labelPredicate = NSPredicate(format: "label == %@", name)
                let el = app.descendants(matching: .any).matching(labelPredicate).firstMatch
                tapElement(element: el)
            }
        }

        tapTab("Sessions")

        if UIDevice.current.userInterfaceIdiom != .pad {
            snapshot("1_SessionList")
        }

        tapRow(app: app, idx: 0)

        snapshot("2_Session")

        tapTab("My Schedule")

        snapshot("3_Favourites")

        tapTab("Info")

        snapshot("4_Info")
    }
}
