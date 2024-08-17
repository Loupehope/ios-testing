# Snapshot-тесты
1. [Общая информация](#basic)
2. [Библиотеки](#libs)
3. [Пример реализации](#example)

### <a name="basic"></a> Snapshot-тесты - проверяют верстку UI-компонентов и экранов

Принцип работы:
1. Сначала генерируется изображение UI-компонента или экрана, которое сохраняется в файлы проекта
2. Потом сгененрированное изображение используется как эталон при следующих прогонах тестов

Плюсы:
- Не требуют сборки основного хоста приложения (за редким исключением, если требуется сделать снепшот экрана, который должен отобразиться модально)
- Можно быстро проверять верстку как отдельных элементов, так и целых экранов
- Можно проверять самые разные случаи верстки, например, как будет отображаться компонент с длинным текстом или без текста и т.д.
- Удобно проверять во время код ревью изменения, так как есть возможность смотреть дифф до и после
  
Минусы:
- Снепшоты могут занимать много места в репозитории

Решения минусов:
- Переносить снепшоты из репозитория в отдельное хранилище

###  <a name="libs"></a> Библиотеки
- [ios-snapshot-test-case](https://github.com/uber/ios-snapshot-test-case) - бывший проект от facebook, написано на Obj-C.
- [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) - проект от pointfreeco, написано на Swift.

На практике встречается и первая, и вторая библиотека, но я бы отдал предпочтение pointfreeco, так как проект от facebook/uber на данный момент перестал как-либо развиваться.

###  <a name="example"></a> Пример реализации

Дано:
- Хотим проверить верстку некоторой вьюхи [AnalyticsView с кнопкой по центру](../iOSTesting/AnalyticsViewController.swift#L17)
- Хотим понять, что констрейнты выставлены правильно
- Хотим увидеть поведение кнопки с разной длинной текста
- Будем использовать swift-snapshot-testing для тестирования

```swift
final class AnalyticsView: UIView {
    private let analyticsButton = UIButton()
    /// Верстка
    func configure(...) { /// Метод для конфигурирования кнопки }
}
```

Что надо сделать:
1. Создаем [класс в бандле с unit-тестами](../iOSTestingUnitTests/SnapshotUnitTests.swift)
```swift
import UIKit
import SnapshotTesting
import XCTest

@testable import iOSTesting

final class AnalyticsViewSnapshotTests: XCTestCase { }
```
2. Добавляем в этот класс информацию о нашей вьюхе и [методы для создания вью и её очистки](../iOSTestingUnitTests/SnapshotUnitTests.swift#L15) для каждого теста
```swift
final class AnalyticsViewSnapshotTests: XCTestCase {
    private var view: AnalyticsView! // Объект вьюхи

    override func setUp() {
        super.setUp()
        // Нам надо создать вью и задать её размеры для теста
        view = AnalyticsView(); view.frame = .init(origin: .zero, size: .init(width: 100, height: 300))
    }

    override func tearDown() {
        // Чистим ресурсы после каждого теста
        view = nil; super.tearDown()
    }
}
```
3. Добавляем [два теста для проверки поведения кнопки](../iOSTestingUnitTests/SnapshotUnitTests.swift#L30)
```swift
final class AnalyticsViewSnapshotTests: XCTestCase {
    // Настройка вьюхи
    // ...
    func testAnalyticsViewWithLongTextButton() {
        // Конфигурируем вью перед снепшотом
        view.configure(AnalyticsView.ViewModel(buttonTitle: "Really Long Text"))
        // Вызываем проверку из swift-snapshot-testing
        assertSnapshot(of: view, as: .image)
    }

    func testAnalyticsViewWithShortTextButton() {
        // Конфигурируем вью перед снепшотом
        view.configure(AnalyticsView.ViewModel(buttonTitle: "Text"))
        // Вызываем проверку из swift-snapshot-testing
        assertSnapshot(of: view, as: .image)
    }
}
```
4. Теперь достаточно прогнать тесты - в первый раз они упадут, так как только [запишуться эталенные снепшоты](../iOSTestingUnitTests/__Snapshots__/SnapshotUnitTests), которые можно проверить на корректность
5. Если всё ок, то полученный результат можно коммитеть. Теперь в следующий раз, если кто-то поправит констрейнты или цвет кнопки, то снепшоты тесты упадут, так как не совпадут с эталоном
