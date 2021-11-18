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

public protocol LivePlayerViewControllerDelegate: AnyObject {
	func livePlayerViewControllerDidTapClose()
}

/// Wraps SDKLivePlayerView to expose a clean UIKit api.
public class LivePlayerViewController: UIHostingController<SDKLivePlayerView> {
	
	public weak var delegate: LivePlayerViewControllerDelegate?
	
	public convenience init(
        showId: String? = nil,
        defaultsToAspectRatioFit: Bool = false) {
		self.init(rootView: SDKLivePlayerView(didTapClose: {}))
		rootView = SDKLivePlayerView(
			showId: showId,
			didTapClose: { [weak self] in self?.delegate?.livePlayerViewControllerDidTapClose()
            },
			defaultsToAspectRatioFit: defaultsToAspectRatioFit)
		modalPresentationStyle = .fullScreen
	}
}
