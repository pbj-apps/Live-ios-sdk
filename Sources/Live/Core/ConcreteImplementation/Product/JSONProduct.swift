//
//  JSONProduct.swift
//  
//
//  Created by Sacha on 03/03/2021.
//

import Foundation


struct JSONProductResult: Decodable {
	let id: String
	let product: JSONProduct
}

struct JSONProduct: Decodable {
	let title: String
	let description: String
	let price: String
	let store_url: String
	let image: JSONProductImage
}

struct JSONProductImage: Decodable {
	let src: String
}

extension JSONProductResult {
	func toProduct() -> Product {
		return Product(
			id: id,
			title: product.title,
			price: product.price,
			detail: product.description,
			image: URL(string: product.image.src),
			link: URL(string: product.store_url))
	}
}
