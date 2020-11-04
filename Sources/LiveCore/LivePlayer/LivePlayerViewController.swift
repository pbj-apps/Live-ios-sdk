//
//  File.swift
//  
//
//  Created by Sacha on 04/11/2020.
//

import SwiftUI
import Combine


// Will be in Core.
public class LivePlayerViewController: UIViewController {

	private var domain: String = ""
	private var apiKey: String = ""
	public var liveStore: LiveStore?
	var cancellables = Set<AnyCancellable>()
	private var restApi:RestApi?

	public convenience init(domain: String, apiKey: String) {
		self.init(nibName: nil, bundle: nil)
		self.domain = domain
		self.apiKey = apiKey
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		self.restApi = RestApi(apiUrl: "https://\(domain)/api", webSocketsUrl: "wss://\(domain)/ws", apiKey: apiKey)
		self.liveStore = LiveStore(liveStreamRepository: restApi!, chatRepository: nil)

		// At the moment, an authenticated user is needed to get a Livestream.
		restApi?.authenticationToken = "***REMOVED***"


		view.backgroundColor = .white

		showRandomLivestramAvailable()
	}

	func showRandomLivestramAvailable() {
		restApi?.getLiveStreamsSchedule().then{ livestreams in
			if let firstLivestream = livestreams.randomElement() {
				self.showPlayer(liveStream: firstLivestream)
			}
		}
		.sink()
		.store(in: &cancellables)
	}

	private func showPlayer(liveStream: LiveStream) {
		let livePlayerView = AnyView(GeometryReader { proxy in
			LivePlayer(liveStream: liveStream, finishedPlaying: {
				print("Finished playing")
			}, close:  {
				print("close")
			}, proxy: proxy)
		})
		.environmentObject(liveStore!)
		.environmentObject(Theme())

		let livePlayerVC = UIHostingController(rootView: livePlayerView)
		addChild(livePlayerVC)

		livePlayerVC.view.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(livePlayerVC.view)

		livePlayerVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		livePlayerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		livePlayerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		livePlayerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}
}
