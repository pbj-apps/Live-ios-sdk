//
//  ViewController.swift
//  LiveExampleAppUIKit
//
//  Created by Sacha on 03/11/2020.
//

import UIKit
import LiveCore // 1) Import Live.

class ViewController: UIViewController {

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// 2) Create a LivePlayerViewController with your credentials
		let livePlayerVC = LivePlayerViewController(domain: "api.pbj-live.dev.pbj.engineering",
																								apiKey: "pk_OllxJqe45s4ofRuTP3yHADCBNraEyXjcds1ZufBiOCwoKjrkkt1ecpBuKNNSxfvREBKROe" +
																									"fKOBq3aCkbLUviVv7T24vFQGxuA6kX9vpwMuqBfX7sviF8ZA5c72dw3wzeFRKnoY9nzwGCOLyoJlR")
		livePlayerVC.modalPresentationStyle = .fullScreen
		present(livePlayerVC, animated: true, completion: nil)
	}
}
