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
		return get("/integrations/shopify/episodes/featured-products", params: ["episode" : episode.id])
			.map { (page: JSONPage<JSONProductResult>) in
				return page.results.map { $0.toProduct() }
			}.eraseToAnyPublisher()
	}
	
	public func fetchProducts(for video: VodVideo) -> AnyPublisher<[Product], Error> {
		return get("/shopping/videos/featured-products", params: ["video" : video.id])
			.map { (page: JSONPage<JSONProductResult>) in
				return page.results.map { $0.toProduct() }
			}.eraseToAnyPublisher()
	}
	
	public func fetchCurrentlyFeaturedProducts(for episode: Episode) -> AnyPublisher<[Product], Error> {
		return get("/integrations/shopify/episodes/featured-products/highlighted", params: ["episode" : episode.id])
			.map { (page: JSONPage<JSONProductResult>) in
				return page.results.map { $0.toProduct() }
			}.eraseToAnyPublisher()
	}
	
	public func registerForProductHighlights(for episode: Episode) -> AnyPublisher<ProductUpdate, Never> {
		webSocket.registerForProductHighlights(for: episode)
	}
	
	public func unRegisterProductHighlights(for episode: Episode) {
		webSocket.unRegisterProductHighlights(for: episode)
	}
}

extension JSONProductResult: NetworkingJSONDecodable {}
