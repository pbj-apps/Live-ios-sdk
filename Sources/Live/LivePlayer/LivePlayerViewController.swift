//
//  LivePlayerViewController.swift
//  
//
//  Created by Sacha on 04/11/2020.
//

import SwiftUI
import Combine
import AVKit

public class LiveSDK {

	static let shared = LiveSDK()
	var domain: String = ""
	var apiKey: String = ""

	public static func initialize(withDomain: String, apiKey: String) {
		shared.domain = withDomain
		shared.apiKey = apiKey
	}
}

public protocol LivePlayerViewControllerDelegate {
	func livePlayerViewControllerDidTapClose()
}

public class LivePlayerViewController: UIViewController, ObservableObject {

	public var delegate: LivePlayerViewControllerDelegate?
	private var cancellables = Set<AnyCancellable>()
	private var api: RestApi!
	private var liveStreamId: String?
	private var livePlayerViewModel: LivePlayerViewModel?

	public override func loadView() {
		view = LivePlayerViewControllerView()
	}

	public convenience init() {
		self.init(nibName: nil, bundle: nil)
		setup()
	}

	public convenience init(liveStreamId: String) {
		self.init(nibName: nil, bundle: nil)
		self.liveStreamId = liveStreamId
		setup()
	}

	private func setup() {
		let domain = LiveSDK.shared.domain
		let apiKey = LiveSDK.shared.apiKey
		self.api = RestApi(apiUrl: "https://\(domain)/api", webSocketsUrl: "wss://\(domain)/ws", apiKey: apiKey)
		// At the moment, an authenticated user is needed to get a Livestream.
		// TODO Remove and replace by the correct authentication method.
		api.authenticationToken = "***REMOVED***"
		modalPresentationStyle = .fullScreen
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		api.getLiveStreams().map { [unowned self] liveStreams -> LiveStream in
			if let liveStreamFound = liveStreams.first(where: { $0.id == self.liveStreamId }) {
				return liveStreamFound
			} else {
				return liveStreams.randomElement()!
			}
		} .map { [unowned self] liveStream in
			self.livePlayerViewModel = LivePlayerViewModel(liveStream: liveStream)
			self.showPlayer()
		}
		.sink()
		.store(in: &cancellables)
	}

	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		api.registerForRealTimeLiveStreamUpdates()
			.receive(on: RunLoop.main)
			.sink { [unowned self] update in
				if let liveStream = self.livePlayerViewModel?.liveStream, update.id == liveStream.id {
					self.livePlayerViewModel?.liveStream.waitingRomDescription = update.waitingRoomDescription
					self.livePlayerViewModel?.liveStream.status = update.status
					if update.status == .broadcasting { // Fetch broadcastURL
						self.fetchBroadcastURL(liveStream: liveStream)
					}
				}
			}.store(in: &cancellables)
	}

	func fetchBroadcastURL(liveStream: LiveStream) {
		api.fetchBroadcastUrl(for: liveStream)
			.receive(on: RunLoop.main)
			.then { [unowned self] broadcastURL in
				self.livePlayerViewModel?.liveStream.broadcastUrl = broadcastURL
			}
			.sink()
			.store(in: &cancellables)
	}

	public override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		api.leaveRealTimeLiveStreamUpdates()
	}

	private func showPlayer() {
		let livePlayerView = AnyView(
			GeometryReader { proxy in
				LivePlayer(
					viewModel: self.livePlayerViewModel!,
					finishedPlaying: { print("Finished playing") },
					close: { [weak self] in
						self?.delegate?.livePlayerViewControllerDidTapClose()
					},
					proxy: proxy,
					isAllCaps: false,
					regularFont: "HelveticaNeue",
					lightFont: "Helvetica-Light",
					lightForegroundColor: .white,
					imagePlaceholderColor: Color(red: 239.0/255, green: 239.0/255, blue: 239.0/255),
					accentColor: .black,
					remindMeButtonBackgroundColor: .white,
					isChatEnabled: false,
					chatMessages: [],
					fetchMessages: {},
					sendMessage: { _ in }
				)
			})

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
