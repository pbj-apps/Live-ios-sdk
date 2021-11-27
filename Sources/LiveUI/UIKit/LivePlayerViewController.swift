//
//  LivePlayerViewController.swift
//  
//
//  Created by Sacha DSO on 18/11/2021.
//

import SwiftUI
import Combine
import AVKit
import Networking
import Live

public protocol LivePlayerViewControllerDelegate: AnyObject {
	func livePlayerViewControllerDidTapClose()
}

/// Wraps LivePlayer to expose a clean UIKit api.
public class LivePlayerViewController: UIHostingController<LivePlayer> {
	
	public weak var delegate: LivePlayerViewControllerDelegate?
	
	public convenience init(
		episode: Episode,
		defaultsToAspectRatioFit: Bool = false) {
			self.init(rootView: LivePlayer(episode: Episode(id: ""), close: {}))
			rootView = LivePlayer(episode: episode,
														liveRepository: RestApi.shared,
														close: { [weak self] in
				self?.delegate?.livePlayerViewControllerDidTapClose()
			},
														defaultsToAspectRatioFit: defaultsToAspectRatioFit)
			modalPresentationStyle = .fullScreen
		}
}
