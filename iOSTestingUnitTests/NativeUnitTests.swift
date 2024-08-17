//
//  iOSTestingUnitTests.swift
//  iOSTestingUnitTests
//
//  Created by Vlad Suhomlinov on 16.08.2024.
//

import XCTest
import UIKit

@testable import iOSTesting

final class NativeAnalyticsViewControllerTests: XCTestCase {
    private var analyticsServiceMock: TracksAnalyticsMock!
    private var contentViewMock: DisplaysAnalyticsViewMock!
    private var analyticsViewController: AnalyticsViewController!

    override func setUp() {
        super.setUp()

        analyticsServiceMock = TracksAnalyticsMock()
        contentViewMock = DisplaysAnalyticsViewMock()

        analyticsViewController = AnalyticsViewController(analyticsService: analyticsServiceMock)
        analyticsViewController.contentView = contentViewMock
    }

    override func tearDown() {
        analyticsServiceMock = nil
        contentViewMock = nil
        analyticsViewController = nil

        super.tearDown()
    }

    func testInit() {
        // when
        analyticsViewController = AnalyticsViewController()
        // then
        XCTAssertTrue(type(of: analyticsViewController.contentView) == AnalyticsView.self)
        XCTAssertIdentical(analyticsViewController.analyticsService, AnalyticsService.shared)
    }

    func testLoadView() {
        // when
        analyticsViewController.loadView()
        // then
        XCTAssertIdentical(analyticsViewController.view, contentViewMock)
    }

    func testViewDidLoad() {
        // given
        let expectedViewModel = AnalyticsView.ViewModel(buttonTitle: "Analytics!")
        let expectedEvent = "View did load!"
        // when
        analyticsViewController.viewDidLoad()
        // then
        XCTAssertEqual(analyticsServiceMock.trackEventWasCalled, 1)
        XCTAssertEqual(analyticsServiceMock.trackEventReceivedEvent, expectedEvent)
        XCTAssertEqual(contentViewMock.configureWasCalled, 1)
        XCTAssertEqual(contentViewMock.configureReceivedViewModel, expectedViewModel)
    }
}
