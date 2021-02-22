//
//  ViewController.swift
//  LiveExampleAppUIKit
//
//  Created by Sacha on 03/11/2020.
//

import UIKit
import Live // 1) Import Live.

class ViewController: UIViewController {

	var selectedEnvironment: ApiEnvironment = .dev
	static let pbjLivePink = UIColor(red: 232/255.0, green: 56/255.0, blue: 109/255.0, alpha: 1)

	private let button: UIButton = {
		let button = UIButton()
		button.setTitle("Watch Live", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.setBackgroundColor(pbjLivePink, for: .normal)
		button.layer.cornerRadius = 6
		button.clipsToBounds = true
		return button
	}()

	private let apiKeyLabel: UILabel = {
		let label = UILabel()
		label.text = "Organization Api Key:"
		label.textColor = .white
		return label
	}()

	private let textField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Enter your Organization Api Key"
		textField.textAlignment = .center
		textField.backgroundColor = .white
		textField.layer.cornerRadius = 6
		return textField
	}()

	private let showIdLabel: UILabel = {
		let label = UILabel()
		label.text = "Show Id (Optional):"
		label.textColor = .white
		return label
	}()

	private let showTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Enter your show Id"
		textField.textAlignment = .center
		textField.backgroundColor = .white
		textField.layer.cornerRadius = 6
		return textField
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "PBJ Live"
		navigationController?.navigationBar.prefersLargeTitles = true

		let textAttributes = [NSAttributedString.Key.foregroundColor: ViewController.pbjLivePink]
		navigationController?.navigationBar.largeTitleTextAttributes = textAttributes

		view.backgroundColor = UIColor(red: 36/255.0, green: 23/255.0, blue: 77/255.0, alpha: 1)

		let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
		view.addGestureRecognizer(tap)

		// Set Org api Key from previous launches.
		if let orgApiKey = UserDefaults.standard.string(forKey: "org_api_key") {
			textField.text = orgApiKey
		}

		let stackView = UIStackView(arrangedSubviews: [
			apiKeyLabel,
			textField,
			showIdLabel,
			showTextField,
			button
		])
		stackView.distribution = .equalSpacing
		stackView.axis = .vertical
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = 20
		view.addSubview(stackView)
		stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
		stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
		stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true

		textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
		showTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
		button.heightAnchor.constraint(equalToConstant: 60).isActive = true

		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)


		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
		textField.delegate = self
		showTextField.delegate = self
	}

	@objc
	func tapped() {
		textField.resignFirstResponder()
	}

	func setUpPicker() {
		let picker = UIPickerView()
		picker.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(picker)
		picker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		picker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
		picker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
		picker.dataSource = self
		picker.delegate = self
	}

	@objc
	func buttonTapped() {
		guard let apiKey = textField.text, !apiKey.isEmpty else {
			return
		}

		// 2) Setup SDK with your API Key
		// This is typically done in the AppDelegate but we do it here
		// Because we want to change org api key at runtime.
		LiveSDK.initialize(apiKey: apiKey, environment: selectedEnvironment)

		// 3) Create a LivePlayerViewController

		var livePlayerVC: LivePlayerViewController
		if let showId = showTextField.text, !showId.isEmpty {
			livePlayerVC = LivePlayerViewController(showId: showId)
		} else {
			livePlayerVC = LivePlayerViewController() // Optionally pass in a LivestreamId to target a specific show.
		}

		livePlayerVC.delegate = self
		present(livePlayerVC, animated: true, completion: nil)

		// Save Org api Key for future app launches.
		UserDefaults.standard.setValue(apiKey, forKey: "org_api_key")
		UserDefaults.standard.synchronize()
	}
}

extension ViewController: LivePlayerViewControllerDelegate {

	func livePlayerViewControllerDidTapClose() {
		self.dismiss(animated: true, completion: nil)
	}
}

extension ViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
	}
}

extension ViewController: UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return ApiEnvironment.allCases.count
	}
}

extension ViewController: UIPickerViewDelegate {

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		let env = ApiEnvironment.allCases[row]
		switch env {
		case .dev:
			return "dev"
		case .demo:
			return "demo"
		case .prod:
			return "prod"
		}
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selectedEnvironment = ApiEnvironment.allCases[row]
	}
}


extension UIButton {
		// https://stackoverflow.com/questions/14523348/how-to-change-the-background-color-of-a-uibutton-while-its-highlighted
		private func image(withColor color: UIColor) -> UIImage? {
				let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
				UIGraphicsBeginImageContext(rect.size)
				let context = UIGraphicsGetCurrentContext()

				context?.setFillColor(color.cgColor)
				context?.fill(rect)

				let image = UIGraphicsGetImageFromCurrentImageContext()
				UIGraphicsEndImageContext()

				return image
		}

	func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
				self.setBackgroundImage(image(withColor: color), for: state)
		}
}
