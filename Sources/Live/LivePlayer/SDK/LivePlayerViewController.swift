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

public protocol LivePlayerViewControllerDelegate {
	func livePlayerViewControllerDidTapClose()
}

public class LivePlayerViewController: UIViewController, ObservableObject {

	public var delegate: LivePlayerViewControllerDelegate?
	private var cancellables = Set<AnyCancellable>()

	private var showId: String?
	private var sdkPlayerViewModel = SDKPlayerViewModel()

	public convenience init() {
		self.init(nibName: nil, bundle: nil)
		modalPresentationStyle = .fullScreen
	}

	public convenience init(showId: String) {
		self.init(nibName: nil, bundle: nil)
		self.showId = showId
		modalPresentationStyle = .fullScreen
	}

	private func setupSwiftUIView() {
		let hostVC = UIHostingController(rootView: SDKPlayerView(viewModel: sdkPlayerViewModel))
		addChild(hostVC)
		hostVC.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(hostVC.view)
		hostVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		hostVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		hostVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		hostVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		setupSwiftUIView()

		sdkPlayerViewModel.didTapClose = { [weak self] in
			self?.delegate?.livePlayerViewControllerDidTapClose()
		}

		sdkPlayerViewModel.load(showId: showId)
	}

//
//	func showAlert(for error: Error) {
//		let netError = (error as? NetworkingError)
//		let alertVC = UIAlertController(
//			title: "Error",
//			message: "\(netError?.code.description ?? "") \(netError?.jsonPayload ?? "") ",
//			preferredStyle: UIAlertController.Style.alert)
//		alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { a in
//			self.dismiss(animated: true, completion: nil)
//		}))
//		self.present(alertVC, animated: true, completion: nil)
//	}

	public override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		LiveSDK.shared.api.leaveRealTimeLiveStreamUpdates()
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

