//
//  ViewController.swift
//  LiveExampleAppUIKit
//
//  Created by Sacha on 03/11/2020.
//

import UIKit
import Live // 1) Import Live.

class ViewController: UIViewController {

	var selectedEnvironment: Environment = .dev

	private let button = UIButton()
	private let textField = UITextField()

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Home"
		view.backgroundColor = .white
		setUpButton()
		setUptextField()
		setUpPicker()
		let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
		view.addGestureRecognizer(tap)

		// Set Org api Key from previous launches.
		if let orgApiKey = UserDefaults.standard.string(forKey: "org_api_key") {
			textField.text = orgApiKey
		}
	}

	@objc
	func tapped() {
		textField.resignFirstResponder()
	}

	func setUpButton() {
		button.setTitle("Watch Live", for: .normal)
		button.setTitleColor(.blue, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(button)
		button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
		button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
	}

	func setUptextField() {
		textField.placeholder = "Enter your Organization Api Key"
		textField.textAlignment = .center
		textField.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(textField)
		textField.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20).isActive = true
		textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
		textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
		textField.delegate = self
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
		let livePlayerVC = LivePlayerViewController() // Optionally pass in a LivestreamId to target a specific show.
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
		return Environment.allCases.count
	}
}

extension ViewController: UIPickerViewDelegate {

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		let env = Environment.allCases[row]
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
		selectedEnvironment = Environment.allCases[row]
	}
}
