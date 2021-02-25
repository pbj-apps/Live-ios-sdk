//
//  LivePlayerViewController.swift
//  
//
//  Created by Sacha on 04/11/2020.
//

import SwiftUI
import Combine
import AVKit
import Networking

public enum ApiEnvironment: CaseIterable {
	case dev
	case demo
	case prod
}

public class LiveSDK {

	internal static let shared = LiveSDK()
	internal var api: RestApi!
	private var cancellables = Set<AnyCancellable>()

	public static func initialize(apiKey: String, environment: ApiEnvironment = .prod) {
		shared.api = RestApi(apiUrl: "https://\(environment.domain)/api",
												 webSocketsUrl: "wss://\(environment.domain)/ws", apiKey: apiKey)
	}

	public static func isEpisodeLive() -> AnyPublisher<Bool, Error> {
		return shared.isEpisodeLive()
	}

	func isEpisodeLive() -> AnyPublisher<Bool, Error> {
		api.authenticateAsGuest().flatMap { [unowned self] in
			self.api.getCurrentLiveStream()
		}
		.map { $0 != nil }
		.eraseToAnyPublisher()
	}

	public static func isEpisodeLive(completion: @escaping (Bool, Error?) -> Void) {
		isEpisodeLive().sink { receiveCompletion in
			switch receiveCompletion {
			case .finished: ()
			case .failure(let error):
				completion(false, error)
			}
		} receiveValue: {
			completion($0, nil)
		}.store(in: &shared.cancellables)
	}
}

public protocol LivePlayerViewControllerDelegate {
	func livePlayerViewControllerDidTapClose()
}

public class LivePlayerViewController: UIViewController, ObservableObject {

	public var delegate: LivePlayerViewControllerDelegate?
	private var cancellables = Set<AnyCancellable>()

	private var showId: String?
	private var livePlayerViewModel: LivePlayerViewModel?

	public override func loadView() {
		view = LivePlayerViewControllerView()
	}

	public convenience init() {
		self.init(nibName: nil, bundle: nil)
		modalPresentationStyle = .fullScreen
	}

	public convenience init(showId: String) {
		self.init(nibName: nil, bundle: nil)
		self.showId = showId
		modalPresentationStyle = .fullScreen
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		LiveSDK.shared.api.authenticateAsGuest().flatMap { [unowned self] () -> AnyPublisher<LiveStream?, Error>  in
			self.registerForRealTimeLiveStreamUpdates()
			return (showId == nil) ? LiveSDK.shared.api.getCurrentLiveStream() : LiveSDK.shared.api.getCurrentLiveStream(from: showId!)
		}.map { [unowned self] currentLiveStream in
			if let liveStream = currentLiveStream {
				self.fetchBroadcastURL(liveStream: liveStream)
				self.livePlayerViewModel = LivePlayerViewModel(liveStream: liveStream)
				self.showPlayer()
			} else {
				let alertVC = UIAlertController(
					title: "No livestream",
					message: "There is no livestream available at the moment",
					preferredStyle: UIAlertController.Style.alert)
				alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { a in
					self.dismiss(animated: true, completion: nil)
				}))
				present(alertVC, animated: true, completion: nil)
			}
		}.eraseToAnyPublisher()
		.mapError { [unowned self] (error: Publishers.FlatMap<AnyPublisher<LiveStream?, Error>, AnyPublisher<(), Error>>.Failure) -> Error in
			let netError = (error as? NetworkingError)
			let alertVC = UIAlertController(
				title: "Error",
				message: "\(netError?.code.description ?? "") \(netError?.jsonPayload ?? "") ",
				preferredStyle: UIAlertController.Style.alert)
			alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { a in
				self.dismiss(animated: true, completion: nil)
			}))
			self.present(alertVC, animated: true, completion: nil)
			return error
		}
		.sink()
		.store(in: &cancellables)
	}
	
	func registerForRealTimeLiveStreamUpdates() {
		LiveSDK.shared.api.registerForRealTimeLiveStreamUpdates()
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
		LiveSDK.shared.api.fetchBroadcastUrl(for: liveStream)
			.receive(on: RunLoop.main)
			.then { [unowned self] broadcastURL in
				self.livePlayerViewModel?.liveStream.broadcastUrl = broadcastURL
			}
			.sink()
			.store(in: &cancellables)
	}

	public override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		LiveSDK.shared.api.leaveRealTimeLiveStreamUpdates()
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

extension ApiEnvironment {
	var domain: String {
		switch self {
		case .dev:
			return "api.pbj-live.dev.pbj.engineering"
		case .demo:
			return "api.pbj-live.demo.pbj.engineering"
		case .prod:
			return "api.pbj.live"
		}
	}
}

