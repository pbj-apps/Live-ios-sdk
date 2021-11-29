//
//  RestApiPaginator.swift
//  
//
//  Created by Sacha on 31/07/2020.
//

import Foundation
import Combine
import Networking

final public class RestApiPaginator<JSONModel: Decodable, Model>: Paginator {

	public var objects: CurrentValueSubject<[Model], Never> = CurrentValueSubject<[Model], Never>([])
	public var pageSize: Int? {
		didSet {
			guard oldValue != pageSize else { return }
			resetPage()
		}
	}
	private var client: NetworkingClient
	private var currentPath: String!
	private let initialPath: String
	private var nextPath: String?
	private var isLoading: Bool = false
	private var error: Error?
	private let mapping: (JSONModel) -> Model
	private let baseUrl: String
	private var computedPath: String {
		if let pageSize = pageSize, pageSize > 0 {
			let pageSizeKey = "per_page"
			let components = NSURLComponents(string: initialPath)
			components?.queryItems = components?.queryItems?.filter { $0.name != pageSizeKey }
			components?.queryItems?.append(URLQueryItem(name: pageSizeKey, value: String(pageSize)))
			return components?.url?.absoluteString ?? initialPath
		} else {
			return initialPath
		}
	}

	public init(baseUrl: String, _ path: String, client: NetworkingClient, mapping: @escaping (JSONModel) -> Model ) {
		self.baseUrl = baseUrl
		self.initialPath = path
		self.client = client
		self.mapping = mapping
		self.currentPath = computedPath
	}

	public func resetPage() {
		objects.value = []
		nextPath = nil
		currentPath = computedPath
	}

	public var hasNextPage: Bool {
		return nextPath != nil
	}

	public func fetchNextPage() -> AnyPublisher<[Model], Error> {
		if let nextPath = nextPath {
			currentPath = nextPath
		}
		nextPath = nil
		isLoading = true
		error = nil
		return client.get(currentPath).then { [unowned self] (page: JSONPage<JSONModel>) in
			if self.currentPath == self.computedPath {
				self.objects.send([])
			}

			let newObjects = page.results.map { mapping($0) }
			let objects = self.objects.value + newObjects
			self.objects.send(objects)
			self.nextPath = page.next?.replacingOccurrences(of: baseUrl, with: "")
			return Just(newObjects)
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
