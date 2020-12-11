import XCTest
import Combine
@testable import Live

final class UserTests: XCTestCase {

	var cancellables = Set<AnyCancellable>()

	// Login

	func testMockedLoginSucceeds() {
		let exp = expectation(description: "expectation")
		let sut = MockedUserRepository()
		sut.login(email: "sachadso@gmail.com", password: "1234").then { _ in
			exp.fulfill()
		}
		.sink()
		.store(in: &cancellables)
		waitForExpectations(timeout: 1, handler: nil)
	}

	func testMockedLoginFails() {
		let exp = expectation(description: "expectation")
		let sut = MockedUserRepository()
		sut.login(email: "sachadso@gmail.com", password: "wrong").onError {_ in
			exp.fulfill()
		}
		.sink()
		.store(in: &cancellables)
		waitForExpectations(timeout: 1, handler: nil)
	}

	// Signup

	func testMockedSignupSucceeds() {
		let exp = expectation(description: "expectation")
		let sut = MockedUserRepository()
		sut.signup(email: "sachadso@gmail.com", password: "1234", firstname: "Sacha", lastname: "DSO").then { _ in
			exp.fulfill()
		}
		.sink()
		.store(in: &cancellables)
		waitForExpectations(timeout: 1, handler: nil)
	}

	func testMockedSignupFails() {
		let exp = expectation(description: "expectation")
		let sut = MockedUserRepository()
		sut.signup(email: "", password: "", firstname: "", lastname: "").onError {_ in
			exp.fulfill()
		}
		.sink()
		.store(in: &cancellables)
		waitForExpectations(timeout: 1, handler: nil)
	}

	// CurrentUser

	func testCanGetCurrentUser() {
		let currentUserRepository: CurrentUserRepository = MockedCurrentUserRepository()
		XCTAssertNil(currentUserRepository.getCurrentUser())
		MockedCurrentUserRepository.savedUser = User(firstname: "user1", lastname: "flix", email: "test@user.com", username: "", hasAnsweredSurvey: false)
		XCTAssertNotNil(currentUserRepository.getCurrentUser())
	}

	func testCanSetCurrentUser() {
		MockedCurrentUserRepository.savedUser = nil
		let currentUserRepository: CurrentUserRepository = MockedCurrentUserRepository()
		XCTAssertNil(currentUserRepository.getCurrentUser())
		let testUser = User(firstname: "user1", lastname: "flix", email: "test@user.com", username: "", hasAnsweredSurvey: false)
		currentUserRepository.setCurrentUser(user: testUser)
		let user = currentUserRepository.getCurrentUser()
		XCTAssertNotNil(user)
		XCTAssertEqual(user?.firstname, "user1")
		XCTAssertEqual(user?.lastname, "flix")
		XCTAssertEqual(user?.email, "test@user.com")
	}

	static var allTests = [
		("testMockedLoginSucceeds", testMockedLoginSucceeds),
		("testMockedLoginFails", testMockedLoginFails),
		("testMockedSignupSucceeds", testMockedSignupSucceeds),
		("testMockedSignupFails", testMockedSignupFails),
		("testCanGetCurrentUser", testCanGetCurrentUser),
		("testCanSetCurrentUser", testCanSetCurrentUser)
	]
}

struct MockedUserRepository: UserRepository {
	
	func changePassword(currentPassword: Password, newPassword: Password) -> AnyPublisher<Void, ChangePasswordError> {
		Just(())
			.setFailureType(to: ChangePasswordError.self)
			.eraseToAnyPublisher()
	}

	func login(email: String, password: String) -> AnyPublisher<User, LoginError> {
		if password == "1234" {
			return Just(User(firstname: "John", lastname: "Doe", email: "johndoe@gmail.com", username: "", hasAnsweredSurvey: false))
				.setFailureType(to: LoginError.self)
				.eraseToAnyPublisher()
		} else {
			return Fail(outputType: User.self, failure: LoginError.unknown)
				.eraseToAnyPublisher()
		}
	}

	func signup(email: Email, password: Password, firstname: String, lastname: String) -> AnyPublisher<User, SignupError> {
		if email != "" {
			return Just(User(firstname: "John", lastname: "Doe", email: "johndoe@gmail.com", username: "", hasAnsweredSurvey: false))
				.setFailureType(to: SignupError.self)
				.eraseToAnyPublisher()
		} else {
			return Fail(outputType: User.self, failure: SignupError.unknown)
				.eraseToAnyPublisher()
		}
	}

	func fetch(user: User) -> AnyPublisher<User, Error> {
		return Just(User(firstname: "John", lastname: "Doe", email: "johndoe@gmail.com", username: "", hasAnsweredSurvey: false))
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}

	func editUser(firstname: String?, lastname: String?) -> AnyPublisher<Void, EditUserError> {
		Just(())
			.setFailureType(to: EditUserError.self)
			.eraseToAnyPublisher()
	}
}

struct MockedCurrentUserRepository: CurrentUserRepository {

	static var savedUser: User?
	func setCurrentUser(user: User) {
		MockedCurrentUserRepository.savedUser = user
	}

	func getCurrentUser() -> User? {
		return MockedCurrentUserRepository.savedUser
	}

	func signOut() {

	}
}
