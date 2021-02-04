//
//  RestApi+User.swift
//  
//
//  Created by Sacha on 21/07/2020.
//

import Foundation
import Combine
import Networking
import UIKit

extension RestApi: UserRepository {

	public func signup(email: Email, password: Password, firstname: String, lastname: String) -> AnyPublisher<User, SignupError> {
		post("/auth/register",
				 params: [
					"email": email,
					"password": password,
					"first_name": firstname,
					"last_name": lastname,
					"username": firstname])
			.map { (user: JSONUser) -> User in
				return user.toUser()
			}
			.mapError { $0.toSignupError() }
			.eraseToAnyPublisher()
	}

	public func login(email: String, password: String) -> AnyPublisher<User, LoginError> {
		authenticationToken = nil
		return post("/auth/login", params: ["email": email, "password": password])
			.map { [unowned self] (jsonUser: JSONUser) -> User in
				self.authenticationToken = jsonUser.authToken
				return jsonUser.toUser()
			}
			.mapError { $0.toLoginError() }
			.eraseToAnyPublisher()
	}

	public func fetch(user: User) -> AnyPublisher<User, Error> {
		return get("/me").map { (jsonUser: JSONUser) -> User in
			return jsonUser.toUser()
		}.eraseToAnyPublisher()
	}

	public func editUser(firstname: String?, lastname: String?) -> AnyPublisher<Void, EditUserError> {
		var params = [String: AnyHashable]()
		if let firstname = firstname {
			params["first_name"] = firstname
		}
		if let lastname = lastname {
			params["last_name"] = lastname
		}
		return patch("/me", params: params)
			.map { (_: JSONUser) -> Void in }
			.mapError { $0.toEditUserError() }
			.eraseToAnyPublisher()
	}

	public func changePassword(currentPassword: Password, newPassword: Password) -> AnyPublisher<Void, ChangePasswordError> {
		return post("/auth/password-change", params: [
			"current_password" : currentPassword,
			"new_password" : newPassword,
		])
		.mapError { $0.toChangePasswordError() }
		.eraseToAnyPublisher()
	}
	
	public func uploadProfilePicture(image: UIImage) -> AnyPublisher<Void, Error> {
		return uploadImageAsset(image: image).flatMap { [unowned self] response -> AnyPublisher<Void, Error> in
			return self.editUserProfileImage(assetId: response.id)
		}
		.eraseToAnyPublisher()
	}
	
	private func uploadImageAsset(image: UIImage) -> AnyPublisher<(JSONUploadAssetResponse), Error> {
		let data = image.jpegData(compressionQuality: 0.5)
		let multipartData = MultipartData(name: "image", fileData: data!, fileName: "profile_picture.jpg", mimeType: "image/jpeg")
		return Future { [unowned self] promise in
			let publisher = network.post("/profile-images", multipartData: multipartData)
			publisher.then { (data, progress) in
				if let data = data {
					if let response = try? JSONDecoder().decode(JSONUploadAssetResponse.self, from: data) {
						promise(.success(response))
					} else {
						promise(.failure(EditUserError.unknown))
					}
				}
			}.onError { error in
				promise(.failure(error))
			}
			.sink()
			.store(in: &self.cancellables)
		}.eraseToAnyPublisher()
	}
	
	private func editUserProfileImage(assetId: String) -> AnyPublisher<Void, Error> {
		return patch("/me", params: ["profile_image": assetId])
			.map { (_: JSONUser) -> Void in }
			.eraseToAnyPublisher()
	}
}

struct JSONUploadAssetResponse: Decodable {
	let id: String
}

extension JSONUploadAssetResponse: NetworkingJSONDecodable {}

private extension Error {
	func toSignupError() -> SignupError {
		return SignupError.unknown
	}
}

private extension Error {
	func toLoginError() -> LoginError {
		if let networkingError = self as? NetworkingError {
			if networkingError.code == 400 {
				if let jsonError = networkingError.jsonPayload as? [String: Any],
					 jsonError["error_type"] as? String == "WrongArguments" {
					return LoginError.wrongCredentials
				}
			}
		}
		return LoginError.unknown
	}
}

private extension Error {
	func toChangePasswordError() -> ChangePasswordError {
		if let networkingError = self as? NetworkingError {
			if networkingError.code == 400 {
				if let jsonError = networkingError.jsonPayload as? [String: Any],
					 jsonError["error_type"] as? String == "ValidationError",
					 let errors = jsonError["errors"] as? [[String: String]],
					 let firstError = errors.first,
					 let firstMessage = firstError["message"] {
					return ChangePasswordError.validationError(wording: firstMessage)
				}
				return ChangePasswordError.unknown
			}
		}
		return ChangePasswordError.unknown
	}
}

typealias ID = String

extension JSONUser: NetworkingJSONDecodable {}

struct JSONUser: Decodable {

	let id: ID
	let firstname: String
	let lastname: String
	let email: Email?
	let username: String
	let authToken: String?
	let hasAnsweredSurvey: Bool?
	let avatarUrl: String?

	enum CodingKeys: String, CodingKey {
		case id
		case first_name
		case last_name
		case email
		case username
		case profile_image
		case is_verified
		case is_staff
		case auth_token
		case is_survey_attempted
	}

	enum ProfileImageKeys: String, CodingKey {
		case image
	}

	enum ImageKeys: String, CodingKey {
		case small
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(String.self, forKey: .id)
		firstname = try values.decode(String.self, forKey: .first_name)
		lastname = try values.decode(String.self, forKey: .last_name)
		email = try? values.decode(String.self, forKey: .email)
		username = try values.decode(String.self, forKey: .username)
		authToken = try? values.decode(String.self, forKey: .auth_token)
		hasAnsweredSurvey = try? values.decode(Bool.self, forKey: .is_survey_attempted)
		if let profileImageValues = try? values.nestedContainer(keyedBy: ProfileImageKeys.self, forKey: .profile_image) {
			let imageValues = try profileImageValues.nestedContainer(keyedBy: ImageKeys.self, forKey: .image)
			avatarUrl = try imageValues.decode(String.self, forKey: .small)
		} else {
			avatarUrl = nil
		}
	}
}

extension JSONUser {
	func toUser() -> User {
		return User(id: id, firstname: firstname, lastname: lastname, email: email, username: username, hasAnsweredSurvey: hasAnsweredSurvey, avatarUrl: avatarUrl)
	}
}

private extension Error {
	func toEditUserError() -> EditUserError {
		return EditUserError.unknown
	}
}
