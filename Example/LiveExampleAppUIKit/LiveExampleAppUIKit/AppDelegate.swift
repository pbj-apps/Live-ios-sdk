//
//  AppDelegate.swift
//  LiveExampleAppUIKit
//
//  Created by Sacha on 03/11/2020.
//

import UIKit
import Live // 1) Import Live

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		// 2) Setup SDK with your domain & API Key
		//		LiveSDK.initialize(apiKey: "ORG_API_KEY")

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = UINavigationController(rootViewController: ViewController())
		window?.makeKeyAndVisible()
		return true
	}
}
