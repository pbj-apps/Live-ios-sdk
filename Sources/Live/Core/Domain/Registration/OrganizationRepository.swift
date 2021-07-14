//
//  OrganizationRepository.swift
//  
//
//  Created by Sacha on 14/07/2021.
//

import Foundation
import Combine

public protocol OrganizationRepository {
	func fetchCurrent() -> AnyPublisher<Organization, Error>
}
