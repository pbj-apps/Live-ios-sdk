//
//  ViewController.swift
//  LiveExampleAppUIKit
//
//  Created by Sacha on 03/11/2020.
//

import UIKit
import Live // 1) Import Live.

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Home"
		view.backgroundColor = .white
		setUpButton()
	}

	func setUpButton() {
		let button = UIButton()
		button.setTitle("Watch Live", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(button)
		button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
	}

	@objc
	func buttonTapped() {
		// 3) Create a LivePlayerViewController
		let livePlayerVC = LivePlayerViewController() // Optionally pass in a LivestreamId to target a specific show.
		livePlayerVC.delegate = self
		present(livePlayerVC, animated: true, completion: nil)
	}
}

extension ViewController: LivePlayerViewControllerDelegate {

	func livePlayerViewControllerDidTapClose() {
		self.dismiss(animated: true, completion: nil)
	}
}
