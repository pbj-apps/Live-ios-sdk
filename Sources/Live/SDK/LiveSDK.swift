//
//  LiveSDK.swift
//  
//
//  Created by Sacha DSO on 27/11/2021.
//

import Foundation
import Combine

public typealias Live = VodRepository & LiveRepository & GuestAuthenticationRepository

public enum LiveSDK {
	
	public static func initialize(apiKey: String,
																environment: ApiEnvironment = .prod,
																logLevels: LiveLogLevel = .off) -> Live {
		return RestApi(apiUrl: "https://\(environment.domain)/api",
									 webSocketsUrl: "wss://\(environment.domain)/ws",
									 apiKey: apiKey,
									 logLevels: logLevels)
	}
}

public enum LiveLogLevel {
		case off
		case info
		case debug
}
