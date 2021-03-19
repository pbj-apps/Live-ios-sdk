//
//  ProductRepository.swift
//  
//
//  Created by Sacha on 03/03/2021.
//

import Foundation
import Combine

public protocol ProductRepository {
	func fetchProducts(for episode: LiveStream) -> AnyPublisher<[Product], Error>
	func fetchCurrentlyFeaturedProducts(for episode: LiveStream) -> AnyPublisher<[Product], Error>
	func registerForProductHighlights(for episode: LiveStream) -> AnyPublisher<ProductUpdate, Never>
	func unRegisterProductHighlights(for episode: LiveStream)
}

public struct ProductUpdate {
	public let products: [Product]
}
