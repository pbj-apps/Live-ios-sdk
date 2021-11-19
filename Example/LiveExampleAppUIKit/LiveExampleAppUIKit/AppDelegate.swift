//
//  AppDelegate.swift
//  LiveExampleAppUIKit
//
//  Created by Sacha on 03/11/2020.
//

import UIKit
import AVKit
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		let audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(.playback)
		} catch {
			print("Setting category to AVAudioSessionCategoryPlayback failed.")
		}
	
		let liveApiVC = UIHostingController(rootView: LiveApiView())
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = UINavigationController(rootViewController: liveApiVC)
		window?.makeKeyAndVisible()
		return true
	}
}
