//
//  RestApiPaginator.swift
//  
//
//  Created by Sacha on 31/07/2020.
//

import Foundation
import Combine
import Networking

final class RestApiPaginator<JSONModel: Decodable, Model>: Paginator {

	var objects: CurrentValueSubject<[Model], Never> = CurrentValueSubject<[Model], Never>([])
	private var client: NetworkingClient
	private var currentPath: String!
	private let initialPath: String
	private var nextPath: String?
	private var isLoading: Bool = false
	private var error: Error?
	private let mapping: (JSONModel) -> Model
	private let baseUrl: String

	init(baseUrl: String, _ path: String, client: NetworkingClient, mapping: @escaping (JSONModel) -> Model ) {
		self.baseUrl = baseUrl
		self.initialPath = path
		self.client = client
		self.mapping = mapping
		self.currentPath = initialPath
	}

	func resetPage() {
		objects.value = []
		nextPath = nil
		currentPath = initialPath
	}

	var hasNextPage: Bool {
		return nextPath != nil
	}

	func fetchNextPage() -> AnyPublisher<Void, Error> {
		if let nextPath = nextPath {
			currentPath = nextPath
		}
		nextPath = nil
		isLoading = true
		error = nil
		return client.get(currentPath).then { [unowned self] (page: JSONPage<JSONModel>) in
			if self.currentPath == self.initialPath {
				self.objects.send([])
			}

			let newObjects = page.results.map { mapping($0) }
			let objects = self.objects.value + newObjects
			self.objects.send(objects)
			self.nextPath = page.next?.replacingOccurrences(of: baseUrl, with: "")
			return Just(())
				.setFailureType(to: Error.self)
				.eraseToAnyPublisher()
		}.onError { error in
			if let networkingError = error as? NetworkingError {
				print(networkingError)
			}
			self.error = error
		}.finally {
			self.isLoading = false
		}
	}
}
