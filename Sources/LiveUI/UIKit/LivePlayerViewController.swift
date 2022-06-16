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

///Wraps LivePlayer to expose a clean UIKit api.
public class LivePlayerViewController: UIViewController {
	
	public weak var delegate: LivePlayerViewControllerDelegate?
	
	private var swiftUIVC: UIViewController?
	
	public override func loadView() {
		view = swiftUIVC?.view ?? UIView()
	}
	
	public convenience init(
		episode: Episode,
		defaultsToAspectRatioFit: Bool = false) {
			self.init(nibName: nil, bundle: nil)
			
			let hostVC = UIHostingController(rootView: LivePlayer(episode: episode,
																														close: { [weak self] in
				self?.delegate?.livePlayerViewControllerDidTapClose()
			}, defaultsToAspectRatioFit: defaultsToAspectRatioFit)
			)
			
			swiftUIVC = hostVC
			modalPresentationStyle = .fullScreen
		}
}

