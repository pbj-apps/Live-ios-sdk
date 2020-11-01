//
//  AnyPaginator.swift
//  
//
//  Created by Sacha on 31/07/2020.
//

import Foundation
import Combine

// Type-erased paginator
public struct AnyPaginator<Model>: Paginator {
	
	public var objects: CurrentValueSubject<[Model], Never>
	private var _resetPage: () -> Void
	private var _fetchNextPage: () -> AnyPublisher<Void, Error>
	private var _hasNextPage: () -> Bool
	
	internal init<T: Paginator>(_ paginator: T) where T.Model == Model {
		objects = paginator.objects
		_resetPage = paginator.resetPage
		_fetchNextPage = paginator.fetchNextPage
		_hasNextPage = { paginator.hasNextPage }
	}
	
	func resetPage() {
		_resetPage()
	}
	
	var hasNextPage: Bool {
		_hasNextPage()
	}
	
	public func fetchNextPage() -> AnyPublisher<Void, Error> {
		_fetchNextPage()
	}
}
