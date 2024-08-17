//
//  AnalyticsMocks.swift
//  iOSTestingUnitTests
//
//  Created by Vlad Suhomlinov on 16.08.2024.
//

import UIKit

@testable import iOSTesting

final class DisplaysAnalyticsViewMock: UIView, DisplaysAnalyticsView {
    // MARK: - configure

    private(set) var configureWasCalled: Int = 0
    private(set) var configureReceivedViewModel: AnalyticsView.ViewModel?

    func configure(_ viewModel: AnalyticsView.ViewModel) {
        configureWasCalled += 1
        configureReceivedViewModel = viewModel
    }
}

final class TracksAnalyticsMock: TracksAnalytics {
    // MARK: - track

    private(set) var trackEventWasCalled: Int = 0
    private(set) var trackEventReceivedEvent: String?

    func track(event: String) {
        trackEventWasCalled += 1
        trackEventReceivedEvent = event
    }
}
