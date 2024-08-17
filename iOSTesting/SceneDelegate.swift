//
//  SceneDelegate.swift
//  iOSTesting
//
//  Created by Vlad Suhomlinov on 16.08.2024.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = AnalyticsViewController()
        window?.makeKeyAndVisible()
    }
}
