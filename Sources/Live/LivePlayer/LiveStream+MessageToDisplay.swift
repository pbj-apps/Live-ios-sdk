//
//  LiveStream+MessageToDisplay.swift
//  
//
//  Created by Sacha on 03/09/2020.
//

import Foundation

public extension LiveStream {
	func messageToDisplay() -> String {
		switch status {
		case .idle:
			return description
		case .waitingRoom:
			return waitingRomDescription
		case .broadcasting:
			return "Streaming"
		case  .finished:
			return "Stream finished"
		}
	}
}
