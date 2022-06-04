//
//  ProductRepository.swift
//  
//
//  Created by Sacha on 03/03/2021.
//

import Foundation
import Combine

public protocol ProductRepository {
	func fetchProducts(for episode: Episode) -> AnyPublisher<[Product], Error>
	func fetchProducts(for episode: Episode) async throws -> [Product]
	
	func fetchProducts(for video: VodVideo) -> AnyPublisher<[Product], Error>
	func fetchProducts(for video: VodVideo) async throws -> [Product]
	
	func fetchCurrentlyFeaturedProducts(for episode: Episode) -> AnyPublisher<[Product], Error>
	func fetchCurrentlyFeaturedProducts(for episode: Episode) async throws -> [Product]
	
	func registerForProductHighlights(for episode: Episode) -> AnyPublisher<ProductUpdate, Never>
	func unRegisterProductHighlights(for episode: Episode)
}

public struct ProductUpdate {
	public let products: [Product]
}
