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
		// 2) Create a LivePlayerViewController with your credentials
		let livePlayerVC = LivePlayerViewController(domain: "api.pbj-live.dev.pbj.engineering",
																								apiKey: "pk_OllxJqe45s4ofRuTP3yHADCBNraEyXjcds1ZufBiOCwoKjrkkt1ecpBuKNNSxfvREBKROe" +
																									"fKOBq3aCkbLUviVv7T24vFQGxuA6kX9vpwMuqBfX7sviF8ZA5c72dw3wzeFRKnoY9nzwGCOLyoJlR", liveStreamId: "0418ea46-c157-4b2c-8fa8-b002857dfdc8")
		livePlayerVC.delegate = self
		present(livePlayerVC, animated: true, completion: nil)
	}
}

extension ViewController: LivePlayerViewControllerDelegate {
	
	func livePlayerViewControllerDidTapClose() {
		self.dismiss(animated: true, completion: nil)
	}
}
