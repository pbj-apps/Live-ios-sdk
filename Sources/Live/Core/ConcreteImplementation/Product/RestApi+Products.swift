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
		return get("/integrations/shopify/episodes/featured-products", params: ["episode" : episode.id])
			.map { (page: JSONPage<JSONProductResult>) in
				return page.results.map { $0.toProduct() }
			}.eraseToAnyPublisher()
	}
}

extension JSONProductResult: NetworkingJSONDecodable {}
