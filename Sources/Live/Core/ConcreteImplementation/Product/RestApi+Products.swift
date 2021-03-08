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
//		return Just(
//			[
//				Product(
//					title: "Apple Airpods",
//					price: "$29.99",
//					detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
//					image: nil,
//					link: nil),
//				Product(title: "Product 2", price: "$45.99", detail: "A cool stuff for sure", image: nil, link: URL(string: "www.google.com")),
//				Product(title: "Product 3", price: "$45.99", detail: "A cool stuff for sure", image: nil, link: URL(string: "www.google.com"))
//			])
//			.setFailureType(to: Error.self)
//			.eraseToAnyPublisher()
		return get("/integrations/shopify/episodes/featured-products", params: ["episode" : episode.id])
			.map { (page: JSONPage<JSONProductResult>) in
				return page.results.map { $0.toProduct() }
			}.eraseToAnyPublisher()
	}
}

extension JSONProductResult: NetworkingJSONDecodable {}
