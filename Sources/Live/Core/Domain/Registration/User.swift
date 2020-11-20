//
//  User.swift
//  
//
//  Created by Sacha on 21/07/2020.
//

import Foundation
import Combine

public struct User: Hashable {
	public var firstname: String
	public var lastname: String
	public let email: Email
	public var username: String
	public var hasAnsweredSurvey: Bool
	public var avatarUrl: String?

	public init(firstname: String, lastname: String, email: Email, username: String, hasAnsweredSurvey: Bool, avatarUrl: String? = nil) {
		self.firstname = firstname
		self.lastname = lastname
		self.email = email
		self.username = username
		self.hasAnsweredSurvey = hasAnsweredSurvey
		self.avatarUrl = avatarUrl
	}
}
