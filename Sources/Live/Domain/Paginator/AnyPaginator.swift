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
	private var _getPageSize: () -> Int?
	private var _setPageSize: (Int?) -> Void

	internal init<T: Paginator>(_ paginator: T) where T.Model == Model {
		var mutablePaginator = paginator
		objects = mutablePaginator.objects
		_resetPage = mutablePaginator.resetPage
		_fetchNextPage = mutablePaginator.fetchNextPage
		_hasNextPage = { mutablePaginator.hasNextPage }
		_getPageSize = { mutablePaginator.pageSize }
		_setPageSize = { mutablePaginator.pageSize = $0  }
	}

	public func resetPage() {
		_resetPage()
	}

	public var hasNextPage: Bool {
		_hasNextPage()
	}

	public var pageSize: Int? {
		set {
			_setPageSize(newValue)
		}
		get {
			_getPageSize()
		}
	}

	public func fetchNextPage() -> AnyPublisher<Void, Error> {
		_fetchNextPage()
	}
}
