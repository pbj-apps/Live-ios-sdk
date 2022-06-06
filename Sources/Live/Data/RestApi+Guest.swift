//
//  RestApi+Guest.swift
//  
//
//  Created by Sacha DSO on 14/01/2021.
//

import Foundation
import Combine
import Networking

extension RestApi: GuestAuthenticationRepository {
	
	public func authenticateAsGuest() -> AnyPublisher<(), Error> {
		return fetchGuestToken().map { [weak self] r in
			self?.authenticationToken = r.auth_token
		}.eraseToAnyPublisher()
	}
	
	public func authenticateAsGuest() async throws {
		if authenticationToken == nil {
			let response = try await fetchGuestToken()
			authenticationToken = response.auth_token
		} else {
			print("already logged")
		}
	}
	
	private func fetchGuestToken() -> AnyPublisher<JSONGuestAuthResponse, Error> {
		post("/auth/guest/session")
	}
	
	private func fetchGuestToken() async throws -> JSONGuestAuthResponse {
		try await post("/auth/guest/session")
	}
}


public struct JSONGuestAuthResponse: Decodable {
	public let auth_token: String
}
