//
//  AppDelegate.swift
//  LiveExampleAppUIKit
//
//  Created by Sacha on 03/11/2020.
//

import UIKit
import AVKit
import LivePlayer // 1) Import LivePlayer
import Combine

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var cancellables = Set<AnyCancellable>()
	var window: UIWindow?
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		let audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(.playback)
		} catch {
			print("Setting category to AVAudioSessionCategoryPlayback failed.")
		}
		
		// 2) Setup SDK with your API Key
		// LiveSDK.initialize(apiKey: "ORG_API_KEY")
		
//		window = UIWindow(frame: UIScreen.main.bounds)
//		window?.rootViewController = UINavigationController(rootViewController: BasicApiViewController())
//		window?.makeKeyAndVisible()
		
		
		let api = LiveApi(apiKey: "", environment: .dev)
	
		
		api.restApi.authenticateAsGuest().then { [unowned self] in
			api.getVodCategories().then { categories in
				print(categories)
			}.sink()
			.store(in: &self.cancellables)
		}.sink()
			.store(in: &cancellables)

		
		return true
	}
}
