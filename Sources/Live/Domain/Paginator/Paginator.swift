//
//  Paginator.swift
//  
//
//  Created by Sacha on 31/07/2020.
//

import Foundation
import Combine

public protocol Paginator {
	associatedtype Model
	var objects: CurrentValueSubject<[Model], Never> { get }
	func resetPage()
	var hasNextPage: Bool { get }
	func fetchNextPage() -> AnyPublisher<[Model], Error>
	var pageSize: Int? { get set }
}
