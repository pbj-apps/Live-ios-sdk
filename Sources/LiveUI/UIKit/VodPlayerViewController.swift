//
//  VodPlayerViewController.swift
//  
//
//  Created by Sacha DSO on 18/11/2021.
//
import SwiftUI
import Combine
import AVKit
import Networking

public protocol VodPlayerViewControllerDelegate: AnyObject {
	func vodPlayerViewControllerDidTapClose()
}

/// Wraps LiveVodPlayer to expose a clean UIKit api.
public class VodPlayerViewController: UIViewController{
	
	public weak var delegate: VodPlayerViewControllerDelegate?
	
	private var swiftUIVC: UIViewController?
	
	public override func loadView() {
		view = swiftUIVC?.view ?? UIView()
	}
	
	public convenience init(url: URL) {
		self.init(nibName: nil, bundle: nil)
		
		let hostVC = UIHostingController(rootView: VodPlayer(url: url,
																												 close: { [weak self] in
			self?.delegate?.vodPlayerViewControllerDidTapClose()
		}))
		
		swiftUIVC = hostVC
		modalPresentationStyle = .fullScreen
	}
}
