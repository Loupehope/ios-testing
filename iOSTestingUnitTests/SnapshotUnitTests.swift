//
//  SnapshotUnitTests.swift
//  iOSTestingUnitTests
//
//  Created by Vlad Suhomlinov on 16.08.2024.
//

import UIKit
import SnapshotTesting
import XCTest

@testable import iOSTesting

final class AnalyticsViewSnapshotTests: XCTestCase {
    private var view: AnalyticsView!

    override func setUp() {
        super.setUp()

        view = AnalyticsView()
        view.frame = .init(origin: .zero, size: .init(width: 100, height: 300))
    }

    override func tearDown() {
        view = nil

        super.tearDown()
    }

    func testAnalyticsViewWithLongTextButton() {
        // given
        view.configure(AnalyticsView.ViewModel(buttonTitle: "Really Long Text"))
        // then
        assertSnapshot(of: view, as: .image)
    }

    func testAnalyticsViewWithShortTextButton() {
        // given
        view.configure(AnalyticsView.ViewModel(buttonTitle: "Text"))
        // then
        assertSnapshot(of: view, as: .image)
    }
}
