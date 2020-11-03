//
//  ViewController.swift
//  LiveExampleAppUIKit
//
//  Created by Sacha on 03/11/2020.
//

import UIKit
import LiveCore

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

//		let liveStore = LiveStore(liveStreamRepository: <#T##LiveStreamRepository#>, chatRepository: <#T##ChatRepository?#>)
//
//		// 1/ fetch livestream available
//		let livePlayer = LivePlayer(liveStream: <#T##LiveStream#>, nextLiveStream: <#T##LiveStream?#>, currentUser: <#T##User?#>, finishedPlaying: <#T##() -> Void#>, close: <#T##() -> Void#>, proxy: <#T##GeometryProxy#>)


	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		let livePlayerVC = LivePlayerViewController.livePlayer()
		present(livePlayerVC, animated: true, completion: nil)
	}
}


import SwiftUI

class LivePlayerViewController {

	static func livePlayer() -> UIViewController {

		let livePlayerView = LivePlayer(liveStream: fakeLiveStream, finishedPlaying: {
			print("Finished playing")
		})
		return UIHostingController(rootView: livePlayerView)
	}
}



let fakeLiveStream = LiveStream(id: "123",
																title: "Fake Livestream title",
																description: "Fake Livestream Description",
																duration: 1234,
																status: .idle,
																showId: "123",
																broadcastUrl: nil,
																chatMode: ChatMode.disabled,
																instructor: User(firstname: "Instructor John",
																								 lastname: "Instructor Doe",
																								 email: "john@doe.com",
																								 username: "johndoe",
																								 hasAnsweredSurvey: false),
																previewImageUrl: nil,
																previewVideoUrl: nil,
																startDate: Date(),
																endDate: Date(),
																waitingRomDescription: "Wait it's starting soon!")
