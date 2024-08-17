//
//  ViewController.swift
//  iOSTesting
//
//  Created by Vlad Suhomlinov on 16.08.2024.
//

import UIKit

// MARK: - AnalyticsView - кнопка UI, которую хотим покрыть снепшот тестами

/// Протокол, который вью
protocol DisplaysAnalyticsView: UIView {
    func configure(_ viewModel: AnalyticsView.ViewModel)
}

final class AnalyticsView: UIView {
    private let analyticsButton = UIButton()

    init() {
        super.init(frame: .zero)

        addSubview(analyticsButton)

        analyticsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            analyticsButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            analyticsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            analyticsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            analyticsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])

        backgroundColor = .white
        analyticsButton.backgroundColor = .black
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension AnalyticsView: DisplaysAnalyticsView {
    /// Вьюмодель для конфигурирования кнопки
    struct ViewModel: Equatable {
        /// Текст кнопки
        let buttonTitle: String
    }

    /// Метод для конфигурирования кнопки
    func configure(_ viewModel: ViewModel) {
        analyticsButton.setTitle(viewModel.buttonTitle, for: .normal)
    }
}

// MARK: - AnalyticsService - сервис аналитики

/// Протокол, который закрывает сервис аналитики
protocol TracksAnalytics: AnyObject {
    func track(event: String)
}

final class AnalyticsService: TracksAnalytics {
    static let shared = AnalyticsService()

    func track(event: String) { /* Какая-то своя логика */ }
}

// MARK: - AnalyticsViewController - вью контроллер

final class AnalyticsViewController: UIViewController {
    let analyticsService: TracksAnalytics

    lazy var contentView: DisplaysAnalyticsView = AnalyticsView()

    init(
        analyticsService: TracksAnalytics = AnalyticsService.shared
    ) {
        self.analyticsService = analyticsService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        analyticsService.track(event: "View did load!")

        contentView.configure(
            AnalyticsView.ViewModel(buttonTitle: "Analytics!")
        )
    }
}
