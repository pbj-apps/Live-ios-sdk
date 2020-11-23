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
		LiveSDK.initialize(
			withDomain: "api.pbj-live.dev.pbj.engineering",
			apiKey: "pk_OllxJqe45s4ofRuTP3yHADCBNraEyXjcds1ZufBiOCwoKjrkkt1ecpBuKNNSxfvREBKROefKOBq3aCkbLUviVv7T24vFQGxuA6kX9vpwMuqBfX7sviF8ZA5c72dw3wzeFRKnoY9nzwGCOLyoJlR")

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = UINavigationController(rootViewController: ViewController())
		window?.makeKeyAndVisible()
		return true
	}
}
