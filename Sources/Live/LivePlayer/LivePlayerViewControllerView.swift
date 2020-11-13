//
//  LivePlayerViewControllerView.swift
//  
//
//  Created by Sacha on 13/11/2020.
//

import UIKit

public class LivePlayerViewControllerView: UIView {

	let label = UILabel()
	let spinner = UIActivityIndicatorView()

	convenience init() {
		self.init(frame: .zero)

		label.translatesAutoresizingMaskIntoConstraints = false
		spinner.translatesAutoresizingMaskIntoConstraints = false

		addSubview(label)
		addSubview(spinner)

		label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		spinner.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
		spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

		backgroundColor = .black
		label.textColor = .white
		spinner.color = .white
		label.text = "Loading Livestream..."
		spinner.startAnimating()
	}
}
