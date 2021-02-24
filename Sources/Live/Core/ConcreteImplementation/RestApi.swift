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
	public var authenticationToken: String? {
		didSet {
			if let token = authenticationToken {
				network.headers[kAuthorizationKey] = "Bearer \(token)"
			} else {
				network.headers[kAuthorizationKey] = nil
			}
		}
	}

	public var network: NetworkingClient
	internal let baseUrl: String
	internal let webSocket: Websocket!

	var cancellables = Set<AnyCancellable>()

	public init(apiUrl: String, webSocketsUrl: String, apiKey: String) {
		self.baseUrl = apiUrl
		var client = NetworkingClient(baseURL: apiUrl)
		client.logLevels = .off
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
