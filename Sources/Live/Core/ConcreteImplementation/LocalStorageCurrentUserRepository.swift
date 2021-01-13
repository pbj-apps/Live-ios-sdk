//
//  LocalStorageCurrentUserRepository.swift
//  
//
//  Created by Sacha on 23/07/2020.
//

import Foundation

public struct LocalStorageCurrentUserRepository: CurrentUserRepository {

	private let defaults = UserDefaults.standard

	private let kCurrentUserKey = "CurrentUser"

	var getCurrentAuthTokenCall: () -> String?
	var setCurrentAuthTokenCall: (String) -> Void

	public init(getCurrentAuthTokenCall: @escaping () -> String?, setCurrentAuthTokenCall: @escaping (String) -> Void) {
		self.getCurrentAuthTokenCall = getCurrentAuthTokenCall
		self.setCurrentAuthTokenCall = setCurrentAuthTokenCall
	}

	public func setCurrentUser(user: User) {
		let savableUser = SavableUser(
			id: user.id,
			firstname: user.firstname,
			lastname: user.lastname,
			email: user.email,
			username: user.username,
			authToken: getCurrentAuthTokenCall(),
			hasAnsweredSurvey: user.hasAnsweredSurvey)
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(savableUser) {
			defaults.set(encoded, forKey: kCurrentUserKey)
			defaults.synchronize()
		}
	}

	public func getCurrentUser() -> User? {
		if let savedUser = defaults.object(forKey: kCurrentUserKey) as? Data {
			let decoder = JSONDecoder()
			if let loadedUser = try? decoder.decode(SavableUser.self, from: savedUser) {
				if let token = loadedUser.authToken {
					setCurrentAuthTokenCall(token)
				}
				return loadedUser.toUser()
			}
		}
		return nil
	}

	public func signOut() {
		defaults.removeObject(forKey: kCurrentUserKey)
		defaults.synchronize()
	}
}

private struct SavableUser: Codable {
	var id: String
	var firstname: String
	var lastname: String
	var email: Email
	var username: String
	var authToken: String?
	var hasAnsweredSurvey: Bool
}

extension SavableUser {
	func toUser() -> User {
		return User(id: id, firstname: firstname, lastname: lastname, email: email, username: username, hasAnsweredSurvey: hasAnsweredSurvey, avatarUrl: nil)
	}
}
