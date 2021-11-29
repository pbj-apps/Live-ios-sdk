//
//  RestApi+OrganizationRepository.swift
//  
//
//  Created by Sacha on 14/07/2021.
//

import Foundation
import Combine
import Networking

extension RestApi: OrganizationRepository {
	public func fetchCurrent() -> AnyPublisher<Organization, Error> {
		get("/organizations/current").map { (jsonOrganization: JSONOrganization) in
			return jsonOrganization.toOrganization()
		}
		.eraseToAnyPublisher()
	}
}

struct JSONOrganization: Decodable {

	struct JSONOrganizationFeatureFlags: Decodable {
		let is_chat_enabled: Bool
	}

	let name: String
	let feature_flags: JSONOrganizationFeatureFlags
}

extension JSONOrganization: NetworkingJSONDecodable {}

extension JSONOrganization {
	func toOrganization() -> Organization {
		return Organization(name: name, isChatEnabled: feature_flags.is_chat_enabled)
	}
}
