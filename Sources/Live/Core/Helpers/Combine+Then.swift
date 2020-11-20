//
//  Combine+Then.swift
//  
//
//  Created by Sacha on 21/07/2020.
//

import Foundation
import Combine

public extension Publisher {

	func ignoreError() -> AnyPublisher<Output, Never> {
		self.catch { _ in Empty() }.eraseToAnyPublisher()
	}

	func sink() -> AnyCancellable {
		sink(receiveCompletion: { _ in }) { _ in }
	}

	func then<T>(_ block: @escaping (Output) -> T) -> AnyPublisher<T, Failure> {
		map(block).eraseToAnyPublisher()
	}

	func then<T>(_ block: @escaping (Output) -> AnyPublisher<T, Failure>) -> AnyPublisher<T, Failure> {
		flatMap { output -> AnyPublisher<T, Failure> in
			block(output)
		}.eraseToAnyPublisher()
	}

	func then<T>(_ publisher: AnyPublisher<T, Failure>) -> AnyPublisher<T, Failure> {
		flatMap { _ -> AnyPublisher<T, Failure> in
			publisher
		}.eraseToAnyPublisher()
	}

	func onError(_ block: @escaping (Failure) -> Void) -> AnyPublisher<Output, Failure> {
		mapError { error -> Failure in
			block(error)
			return error
		}
		.eraseToAnyPublisher()
	}

	func finally(_ block: @escaping () -> Void) -> AnyPublisher<Output, Failure> {
		map { o -> Output in
			block()
			return o
		}.mapError { e -> Failure in
			block()
			return e
		}.eraseToAnyPublisher()
	}
}
