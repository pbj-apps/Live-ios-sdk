//
//  RestApi.swift
//  
//
//  Created by Sacha on 21/07/2020.
//

import Foundation
import Networking
import Combine

public final class RestApi: NetworkingService {
	
	private let kAuthorizationKey = "Authorization"
	
	public var protectedAuthenticationToken: String?
	
	public var authenticationToken: String? {
		get {
			return lockQueue.sync {
				return protectedAuthenticationToken
			}
		}
		set {
			lockQueue.sync {
				protectedAuthenticationToken = newValue
				if let token = newValue {
					self.network.headers[self.kAuthorizationKey] = "Bearer \(token)"
				} else {
					self.network.headers[self.kAuthorizationKey] = nil
				}
			}
		}
	}

	public var network: NetworkingClient
	internal let baseUrl: String
	internal let webSocket: Websocket!

	var cancellables = Set<AnyCancellable>()
	
	let lockQueue = DispatchQueue(label: "RestApiQueue")

	public init(apiUrl: String,
							webSocketsUrl: String,
							apiKey: String,
							logLevels: LiveLogLevel = .off) {
		self.baseUrl = apiUrl
		let client = NetworkingClient(baseURL: apiUrl)
		client.logLevel = logLevels.toNetworkingLogLevel()
		client.headers["Accept"] = "application/vnd.pbj+json; version=1.0"
		client.headers["X-api-key"] = apiKey
		client.parameterEncoding = .json
		self.network = client
		self.webSocket = Websocket(url: webSocketsUrl, apiKey: apiKey)
		self.webSocket.token = { [weak self] in
			self?.authenticationToken ?? ""
		}
	}
}

extension LiveLogLevel {
	func toNetworkingLogLevel() -> NetworkingLogLevel {
		switch self {
		case .off:
			return .off
		case .info:
			return .info
		case .debug:
			return .debug
		}
	}
}



