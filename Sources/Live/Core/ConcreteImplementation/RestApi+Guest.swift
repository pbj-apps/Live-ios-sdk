//
//  RestApi+Guest.swift
//  
//
//  Created by Sacha DSO on 14/01/2021.
//

import Foundation
import Combine
import Networking

extension RestApi {
	
	func authenticateAsGuest() -> AnyPublisher<(), Error> {
		return fetchGuestToken().map { [weak self] r in
			self?.authenticationToken = r.auth_token
		}.eraseToAnyPublisher()
	}
	
	func fetchGuestToken() -> AnyPublisher<JSONGuestAuthResponse, Error> {
		post("/auth/guest/session")
	}
}


struct JSONGuestAuthResponse: Decodable, NetworkingJSONDecodable {
	let auth_token: String
}
