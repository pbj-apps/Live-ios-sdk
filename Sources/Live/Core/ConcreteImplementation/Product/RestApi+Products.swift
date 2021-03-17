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

	public func fetchProducts(for episode: LiveStream) -> AnyPublisher<[Product], Error> {
		return Just([Product(title: "Fake product", price: "23", detail: "detail stuff no one reads", image: nil, link: nil)])
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
//		return get("/integrations/shopify/episodes/featured-products", params: ["episode" : episode.id])
//			.map { (page: JSONPage<JSONProductResult>) in
//				return page.results.map { $0.toProduct() }
//			}.eraseToAnyPublisher()
	}

	public func registerForProductHighlights(for episode: LiveStream) -> AnyPublisher<ProductUpdate, Never> {
		webSocket.registerForProductHighlights(for: episode)
	}

	public func unRegisterForProductHighlights() {
		webSocket.unRegisterForProductHighlights()
	}
}

extension JSONProductResult: NetworkingJSONDecodable {}
