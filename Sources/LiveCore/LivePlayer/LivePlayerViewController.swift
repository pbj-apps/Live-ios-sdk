//
//  LivePlayerViewController.swift
//  
//
//  Created by Sacha on 04/11/2020.
//

import SwiftUI
import Combine
import AVKit

public protocol LivePlayerViewControllerDelegate {
	func livePlayerViewControllerDidTapClose()
}

public class LivePlayerViewController: UIViewController {

	public var delegate: LivePlayerViewControllerDelegate?
	private var domain: String = ""
	private var apiKey: String = ""
	public var liveStore: LiveStore?
	var cancellables = Set<AnyCancellable>()
	private var restApi:RestApi?
	private var liveStreamId: String?


	public convenience init(domain: String, apiKey: String, liveStreamId: String?) {
		self.init(nibName: nil, bundle: nil)
		self.domain = domain
		self.apiKey = apiKey
		self.liveStreamId = liveStreamId
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		self.restApi = RestApi(apiUrl: "https://\(domain)/api", webSocketsUrl: "wss://\(domain)/ws", apiKey: apiKey)
		self.liveStore = LiveStore(liveStreamRepository: restApi!, chatRepository: nil)

		// At the moment, an authenticated user is needed to get a Livestream.
		restApi?.authenticationToken = "***REMOVED***"


		view.backgroundColor = .black

		addLoadingSpinner()

		var playerShown = false
		liveStore!.$liveStreams.sink { livestreams in
			if !livestreams.isEmpty, !playerShown {

				if let liveStreamId = self.liveStreamId,
					 let index = livestreams.firstIndex(where: { $0.id  == liveStreamId}) {

					self.liveStore?.liveStreamWatchedIndex = index
					Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
						print(self.liveStore?.liveStreamWatched?.id)
						if let livestream = self.liveStore?.liveStreamWatched {
							self.showPlayer(liveStream: livestream)
						}
					}

				} else {
					let randomIndex = Int.random(in: 0..<livestreams.count)
					self.liveStore?.liveStreamWatchedIndex = randomIndex
					Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
						print(self.liveStore?.liveStreamWatched?.id)
						if let livestream = self.liveStore?.liveStreamWatched {
							self.showPlayer(liveStream: livestream)
						}
					}
				}
				playerShown = true
			}
		}.store(in: &cancellables)

		liveStore?.fetchLiveStreams()
	}

	private func addLoadingSpinner() {

		let label = UILabel()
		label.textColor = .white
		label.text = "Loading Livestream..."
		label.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(label)
		label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

		let spinner = UIActivityIndicatorView()
		spinner.color = .white
		spinner.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(spinner)
		spinner.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
		spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		spinner.startAnimating()
	}

	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		liveStore?.listenToLiveStreamUpdates()
	}

	public override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		liveStore?.stopListeningToLiveStreamUpdates()
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
			LivePlayer(liveStore: self.liveStore!, finishedPlaying: {
				print("Finished playing")
			}, close: { [weak self] in
				self?.delegate?.livePlayerViewControllerDidTapClose()
			}, proxy: proxy)
		})
		.environmentObject(Theme())

		let livePlayerVC = UIHostingController(rootView: livePlayerView)
		addChild(livePlayerVC)

		livePlayerVC.view.translatesAutoresizingMaskIntoConstraints = false

		livePlayerVC.view.alpha = 0
		view.addSubview(livePlayerVC.view)

		livePlayerVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		livePlayerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		livePlayerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		livePlayerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

		UIView.animate(withDuration: 0.3) {
			livePlayerVC.view.alpha = 1
		}
	}
}
