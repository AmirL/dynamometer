//
//  DynamometerUITests.swift
//  DynamometerUITests
//
//  Created by Amir on 09.08.2025.
//

import XCTest

final class DynamometerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TESTS_SEED_DATA", "UI_TESTS_IN_MEMORY"]
        app.launch()
        
        app.tabBars.buttons["Chart"].tap()
        
        // Wait for the chart view to load - either the chart or a content unavailable view
        let chartExists = app.otherElements["chart_container"].waitForExistence(timeout: 3)
        let noDataExists = app.staticTexts["No Data"].waitForExistence(timeout: 1)
        let configureBaselineExists = app.staticTexts["Configure Baseline"].waitForExistence(timeout: 1)
        
        if !chartExists && (noDataExists || configureBaselineExists) {
            XCTFail("Chart not available - either no data seeded or no settings configured")
        }
        
        // If chart exists, test the period selection
        if chartExists {
            let allButton = app.buttons["period_all"]
            XCTAssertTrue(allButton.waitForExistence(timeout: 2))
            allButton.tap()
            XCTAssertTrue(app.otherElements["chart_container"].waitForExistence(timeout: 2))
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
