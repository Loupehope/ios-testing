# Unit-тесты
1. [Общая информация](#basic)
2. [Библиотеки](#libs)
3. [Пример реализации на XCTest](#example1)
4. [Пример реализации на Quick/Nimble](#example2)

### <a name="basic"></a> Unit-тесты - проверяют методы, функции, свойства объектов

Принцип работы:
1. Создается класс/структура с методами, функциями и свойствами
2. Все зависимости, которые есть в классе/структуре закрываются протоколами
3. Пишуться или генерируются моки для зависимостей
4. Создается класс для тестов
5. Для каждого публичного метода, функции и свойства пишется свой тест

Плюсы:
- Не требуют сборки основного хоста приложения (за редким исключением, если требуется например shared сущность апп делегата)
- Можно быстро проверять логику работы каждого метода, функции или свойства
  
Минусы:
- Если работать с асинхронными методами, то тесты могут флакать
- Могут быть проблемы с рефакторингом или апдейтом логики, если кода очень много в тестах

Решения минусов:
- Все сущности, которые выполняют асинхронную работу, должны закрываться протоколами и переданные замыкания в них должны вызываться синхронно
- Если файл с тестами очень большой, то надо разделять тестируемую сущность на отдельные классы, каждый из которых тестировать отдельно

Базовые термины:
- Flaky тест - тест, который иногда проходит, а иногда нет
- Мок - это тестовый объект, который имитирует какую-либо зависимость. Мок не несет с собой какую-либо реальную логику, а лишь записывает информацию полезную для тестирования: сколько раз был вызван тот или иной метод, какие параметры были переданы в метод и т.д.
```swift
// Есть какой-то протокол, который закрывает зависимость в каком-то классе
protocol TracksAnalytics: AnyObject {
    func track(event: String)
}

// Мы хотим, для теста этого класса заменить реальную аналитику на мок
// 1. Для этого создаем класс с суффиксом Mock и говорим, что он реализует этот мок
// 2. Дополняем методы мока доп логикой для тестов - проверяем кол-во раз, сколько был вызван метод track(event:) и с какими параметрами
final class TracksAnalyticsMock: TracksAnalytics {
    // MARK: - track

    private(set) var trackEventWasCalled: Int = 0
    private(set) var trackEventReceivedEvent: String?

    func track(event: String) {
        trackEventWasCalled += 1
        trackEventReceivedEvent = event
    }
}
```

- Стаб - это тестовый объект, который можно использовать в качестве возвращаемого объекта в методах, функциях и свойствах моков
```swift
// Вернемся к примеру с аналитикой выше и представим, что метод track(event:) возвращает еще в результате Bool флаг - успех или не успех трекинга
protocol TracksAnalytics: AnyObject {
    func track(event: String) -> Bool
}

// Тогда в мок добавится еще поле trackEventResultStub, которое мы сможем настраивать в рамках тестов, тем самым контролируя поведение зависимости
final class TracksAnalyticsMock: TracksAnalytics {
    // MARK: - track
    // ...
    private(set) var trackEventResultStub: Bool!

    func track(event: String) -> Bool {
        // ...
        return trackEventResultStub
    }
}
```

###  <a name="libs"></a> Библиотеки
- [XCTest](https://developer.apple.com/documentation/XCTest) - библиотека от Apple. Все остальные билиотеки - надстройки над ней.
- [Quick/Nimble](https://github.com/Quick/Nimble) - фреймворк, которые позволяет писать тесты удобнее и лаконичнее. Обычно он используется на проектах.

###  <a name="example1"></a> Пример реализации на XCTest

* Готовый код тестов можно посмотреть в [iOSTestingUnitTests](../iOSTestingUnitTests/NativeUnitTests.swift)

Дано:
- Есть некоторый контроллер AnalyticsViewController, в котором есть логика настройки View и вызова сервиса аналитики
- Хотим протестировать, что View конфигурируется корректными параметрами
- Хотим протестировать, что в корневую View устанавливается свойство contentView
- Хотим протестировать, что сервис аналитики был вызван с корректными параметрами

```swift
final class AnalyticsViewController: UIViewController {
    let analyticsService = AnalyticsService.shared

    lazy var contentView = AnalyticsView()

    override func loadView() { view = contentView }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        analyticsService.track(event: "View did load!")
    
        contentView.configure(
            AnalyticsView.ViewModel(buttonTitle: "Analytics!")
        )
    }
}
```

Что надо сделать:
1. Найти все зависимости в классе и создать для них протоколы. В нашем случае зависимости - это View и сервис аналитики:
```swift
// Новый протокол для аналитики
protocol TracksAnalytics: AnyObject {
    func track(event: String)
}
extension AnalyticsService: TracksAnalytics { }

// Новый протокол для View
protocol DisplaysAnalyticsView: UIView {
    func configure(_ viewModel: AnalyticsView.ViewModel)
}
extension AnalyticsView: DisplaysAnalyticsView { }
```
2. Далее закрываем протоколами работу с зависимостями в контроллере
```swift
final class AnalyticsViewController: UIViewController {
    let analyticsService: TracksAnalytics

    // Тут от архитектуры, но я не передаю вью в инит. Она и так закрыта internal доступом.
    lazy var contentView: DisplaysAnalyticsView = AnalyticsView()

    init(
        analyticsService: TracksAnalytics = AnalyticsService.shared
    ) {
        self.analyticsService = analyticsService
        super.init(nibName: nil, bundle: nil)
    }
}
```
3. Далее создаются моки для зависимостей:
```swift
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
```
4. Создаем файл с тестами в unit-тестовом бандле. Описываем в нем все требуемые моки и саму тестируемую сущность. Блоки setUp и tearDown вызываются для каждого теста!
```swift
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
}
```
5. Далее уже создаем тесты для каждого метода в analyticsViewController
```swift
import XCTest
import UIKit

@testable import iOSTesting

final class NativeAnalyticsViewControllerTests: XCTestCase {
    // Тестируем дефолтные значения контроллера
    func testInit() {
        // when
        analyticsViewController = AnalyticsViewController()
        // then
        XCTAssertTrue(type(of: analyticsViewController.contentView) == AnalyticsView.self)
        XCTAssertIdentical(analyticsViewController.analyticsService, AnalyticsService.shared)
    }

    // Тестируем, что View устанавливается в контроллер
    func testLoadView() {
        // when
        analyticsViewController.loadView()
        // then
        XCTAssertIdentical(analyticsViewController.view, contentViewMock)
    }

    // Проверяем настройку View и вызовы аналитики
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
```

###  <a name="example2"></a> Пример реализации на Quick/Nimble

* Готовый код тестов можно посмотреть в [iOSTestingUnitTests](../iOSTestingUnitTests/QuickNimbleUnitTests.swift)

Quick/Nimble - это [BDD фреймворк](https://en.wikipedia.org/wiki/Behavior-driven_development), который позволяет описать тест в категориях - given, when, then:
```swift
import XCTest
import UIKit

@testable import iOSTesting

final class NativeAnalyticsViewControllerTests: XCTestCase {
    // MARK: - БЫЛО
    func testViewDidLoad() {
        let expectedViewModel = AnalyticsView.ViewModel(buttonTitle: "Analytics!")
        let expectedEvent = "View did load!"

        analyticsViewController.viewDidLoad()

        XCTAssertEqual(analyticsServiceMock.trackEventWasCalled, 1)
        XCTAssertEqual(analyticsServiceMock.trackEventReceivedEvent, expectedEvent)
        XCTAssertEqual(contentViewMock.configureWasCalled, 1)
        XCTAssertEqual(contentViewMock.configureReceivedViewModel, expectedViewModel)
    }

    // MARK: - СТАЛО
    describe(".viewDidLoad") {
        it("should call analytics service") {
            let expectedViewModel = AnalyticsView.ViewModel(buttonTitle: "Analytics!")
            let expectedEvent = "View did load!"

            analyticsViewController.viewDidLoad()

            expect(analyticsServiceMock.trackEventWasCalled).to(equal(1))
            expect(analyticsServiceMock.trackEventReceivedEvent).to(equal(expectedEvent))
            expect(contentViewMock.configureWasCalled).to(equal(1))
            expect(contentViewMock.configureReceivedViewModel).to(equal(expectedViewModel))
        }
    }
}
```
