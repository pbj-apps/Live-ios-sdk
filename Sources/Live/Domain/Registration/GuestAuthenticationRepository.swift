//
//  GuestAuthenticationRepository.swift
//  
//
//  Created by Sacha DSO on 27/11/2021.
//

import Foundation
import Combine

public protocol GuestAuthenticationRepository {
	func authenticateAsGuest() -> AnyPublisher<Void, Error>
	func authenticateAsGuest() async throws
}
