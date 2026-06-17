import XCTest

final class JavaZoneUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false

        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeLeft
        } else {
            XCUIDevice.shared.orientation = .portrait
        }

        // Dismiss system alerts automatically (e.g. notification permission triggered
        // by FavouriteToggleView the first time a session is added to favourites).
        addUIInterruptionMonitor(withDescription: "System alert") { alert in
            let allow = alert.buttons["Allow"]
            if allow.exists { allow.tap() } else { alert.buttons.firstMatch.tap() }
            return true
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
        app.launchArguments += ["--skip-notifications"]
        setupSnapshot(app)
        app.launch()

        pause()

        // On iPad iOS 26, TabView renders as a _UIFloatingTabBar whose items are
        // _UIFloatingTabBarItemCell. XCUI subscript notation ("Sessions") matches by
        // accessibility identifier, but tab items only have a label — not an identifier.
        // Use a label predicate with .any type to bypass the type mismatch.
        func tapTab(_ name: String) {
            let bar = app.tabBars["Tab Bar"]
            if bar.exists {
                tapElement(element: bar.buttons[name])
            } else {
                let labelPredicate = NSPredicate(format: "label == %@", name)
                let tabEl = app.descendants(matching: .any).matching(labelPredicate).firstMatch
                tapElement(element: tabEl)
            }
        }

        func addFavourite() {
            // On iPad, app.buttons only traverses the FloatingTabBar — the detail pane
            // is a ScrollView (UIScrollView) that must be targeted explicitly.
            // Check existence first: the button may already be favourited from a prior run.
            let addButton = app.scrollViews.firstMatch.buttons["add-to-favourites"]
            if addButton.exists {
                addButton.tap()
                pause()
                // On a fresh simulator the first favourite triggers a notification
                // permission dialog in SpringBoard. Dismiss it if present.
                let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
                if springboard.alerts.firstMatch.exists {
                    let allow = springboard.alerts.buttons["Allow"]
                    if allow.exists { allow.tap() } else { springboard.alerts.buttons.firstMatch.tap() }
                    pause()
                }
            }
        }

        func navigateBackIfNeeded() {
            // The notification alert dismissal may already pop us to the sessions root.
            // Only tap back if a back button actually exists in the navigation bar.
            if app.navigationBars.firstMatch.buttons.element(boundBy: 0).exists {
                app.navigationBars.firstMatch.buttons.firstMatch.tap()
                pause()
            } else {
                pause()
            }
        }

        tapTab("Sessions")

        if UIDevice.current.userInterfaceIdiom != .pad {
            snapshot("1_SessionList")
        }

        // Add 3 favourites from different visible rows before shooting My Schedule.
        // We avoid swipeUp() because it can inadvertently activate the search bar on
        // iPhone (the keyboard then hides the tab bar and breaks tab navigation).
        // Indices 0, 2, 4 are within the 7+ always-visible rows on both devices.
        for pos in 0..<3 {
            tapRow(app: app, idx: pos * 2)
            if pos == 0 { snapshot("2_Session") }
            addFavourite()
            if UIDevice.current.userInterfaceIdiom != .pad {
                navigateBackIfNeeded()
            }
        }

        tapTab("My Schedule")

        // On iPad, tap the first favourite to populate the split-view detail pane.
        if UIDevice.current.userInterfaceIdiom == .pad {
            tapRow(app: app, idx: 0)
        }

        snapshot("3_Favourites")

        tapTab("Info")

        snapshot("4_Info")
    }
}
