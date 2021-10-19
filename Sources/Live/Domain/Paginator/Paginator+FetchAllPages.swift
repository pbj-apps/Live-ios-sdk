//
//  Paginator+FetchAllPages.swift
//  
//
//  Created by Sacha on 31/07/2020.
//

import Foundation
import Combine

public extension Paginator {
	func fetchAllPages() -> AnyPublisher<[Model], Error> {
		var cancellables = Set<AnyCancellable>()
		return Future { promise in
			func fetchNext() {
				fetchNextPage().then { _ in
					if !hasNextPage {
						promise(.success(self.objects.value))
						cancellables.removeAll()
					} else {
						fetchNext()
					}
				}
				.sink()
				.store(in: &cancellables)
			}
			fetchNext()
		}.eraseToAnyPublisher()
	}
}
