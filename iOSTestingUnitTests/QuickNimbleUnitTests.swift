//
//  QuickNimbleUnitTests.swift
//  iOSTestingUnitTests
//
//  Created by Vlad Suhomlinov on 16.08.2024.
//

import UIKit
import Quick
import Nimble

@testable import iOSTesting

final class QuickNimbleAnalyticsViewControllerTests: QuickSpec {
    override class func spec() {
        var analyticsServiceMock: TracksAnalyticsMock!
        var contentViewMock: DisplaysAnalyticsViewMock!
        var analyticsViewController: AnalyticsViewController!

        beforeEach {
            analyticsServiceMock = TracksAnalyticsMock()
            contentViewMock = DisplaysAnalyticsViewMock()

            analyticsViewController = AnalyticsViewController(analyticsService: analyticsServiceMock)
            analyticsViewController.contentView = contentViewMock
        }

        describe(".init") {
            it("should convigure default properties") {
                // when
                analyticsViewController = AnalyticsViewController()
                // then
                expect(analyticsViewController.contentView).to(beAnInstanceOf(AnalyticsView.self))
                expect(analyticsViewController.analyticsService).to(be(AnalyticsService.shared))
            }
        }

        describe(".loadView") {
            it("should set content view") {
                // when
                analyticsViewController.loadView()
                // then
                expect(analyticsViewController.view).to(be(contentViewMock))
            }
        }

        describe(".viewDidLoad") {
            it("should call analytics service") {
                // given
                let expectedViewModel = AnalyticsView.ViewModel(buttonTitle: "Analytics!")
                let expectedEvent = "View did load!"
                // when
                analyticsViewController.viewDidLoad()
                // then
                expect(analyticsServiceMock.trackEventWasCalled).to(equal(1))
                expect(analyticsServiceMock.trackEventReceivedEvent).to(equal(expectedEvent))
                expect(contentViewMock.configureWasCalled).to(equal(1))
                expect(contentViewMock.configureReceivedViewModel).to(equal(expectedViewModel))
            }
        }
    }
}
