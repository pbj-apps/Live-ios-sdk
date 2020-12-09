//
//  UserRepository.swift
//  
//
//  Created by Sacha on 21/07/2020.
//

import Foundation
import Combine

public typealias Email = String
public typealias Password = String

public enum SignupError: Error {
	case emailAlreadyTaken
	case unknown
}

public enum LoginError: Error {
	case wrongCredentials
	case unknown
}

public enum EditUserError: Error {
	case unknown
}

public enum ChangePasswordError: Error {
	case currentPasswordDoesNotMatch
	case newPasswordIsTooCommon
	case unknown
}

public protocol UserRepository {
	func signup(email: Email, password: Password, firstname: String, lastname: String) -> AnyPublisher<User, SignupError>
	func login(email: Email, password: Password) -> AnyPublisher<User, LoginError>
	func fetch(user: User) -> AnyPublisher<User, Error>
	func editUser(firstname: String?, lastname: String?) -> AnyPublisher<Void, EditUserError>
	func changePassword(currentPassword: Password, newPassword: Password) -> AnyPublisher<Void, Error>
}
