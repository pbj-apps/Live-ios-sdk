//
//  Episode+Countdown.swift
//  
//
//  Created by Sacha on 03/09/2020.
//

import Foundation
import Live

public extension Episode {
	func timeUntil() -> String {
		let now = Date()
		if now > endDate {
			return "Finished"
		}
		if now > startDate {
			return "Streaming now"
		}
		let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: startDate)
		if let hours = diffComponents.hour, let minutes = diffComponents.minute, let seconds = diffComponents.second {
			return "\(String(format: "%02d", hours)) \(String(format: "%02d", minutes)) \(String(format: "%02d", seconds))"
		}
		return "..."
	}
}
