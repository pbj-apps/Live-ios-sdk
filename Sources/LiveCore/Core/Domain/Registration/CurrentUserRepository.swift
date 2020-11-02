//
//  CurrentUserRepository.swift
//  
//
//  Created by Sacha on 23/07/2020.
//

import Foundation

public protocol CurrentUserRepository {
	func setCurrentUser(user: User)
	func getCurrentUser() -> User?
	func signOut()
}
