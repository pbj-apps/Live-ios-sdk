//
//  RestApi+Products.swift
//  
//
//  Created by Sacha on 03/03/2021.
//

import Foundation
import Combine
import Networking

extension RestApi: ProductRepository {
	
	public func fetchProducts(for episode: Episode) -> AnyPublisher<[Product], Error> {
		if let vodId = episode.vodId {
			let video = VodVideo(id: vodId, title: "", description: "", isFeatured: false, thumbnailImageUrl: nil, videoURL: nil, duration: nil)
			return fetchProducts(for: video)
		}
		return get("v1/shopping/episodes/\(episode.id)/featured-products")
			.map { (page: JSONPage<JSONProductResult>) in
				return page.results.map { $0.toProduct() }
			}.eraseToAnyPublisher()
	}
	
	public func fetchProducts(for episode: Episode) async throws -> [Product] {
		if let vodId = episode.vodId {
			let video = VodVideo(id: vodId, title: "", description: "", isFeatured: false, thumbnailImageUrl: nil, videoURL: nil, duration: nil)
			return try await fetchProducts(for: video)
		}
		let page: JSONPage<JSONProductResult> = try await get("/v1/shopping/episodes/\(episode.id)/featured-products")
		return page.results.map { $0.toProduct() }
	}
	
	public func fetchProducts(for video: VodVideo) -> AnyPublisher<[Product], Error> {
		return get("/shopping/videos/featured-products", params: ["video" : video.id])
			.map { (page: JSONPage<JSONProductResult>) in
				return page.results.map { $0.toProduct() }
			}.eraseToAnyPublisher()
	}
	
	public func fetchProducts(for video: VodVideo) async throws -> [Product] {
		let page: JSONPage<JSONProductResult> = try await get("/v1/shopping/videos/\(video.id)/featured-products")
		return page.results.map { $0.toProduct() }
	}
	
	public func registerForProductHighlights(for episode: Episode) -> AnyPublisher<ProductUpdate, Never> {
		webSocket.registerForProductHighlights(for: episode)
	}
	
	public func unRegisterProductHighlights(for episode: Episode) {
		webSocket.unRegisterProductHighlights(for: episode)
	}
}
