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
	let highlight_timings: [JSONProductHighlightedTiming]?
}

struct JSONProductHighlightedTiming: Decodable {
	let start_time: String
	let end_time: String
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

extension JSONProductHighlightedTiming {
	func toProductHighlightedTiming() -> ProductHighlightedTiming? {
		if let start = start_time.toSeconds(), let end = end_time.toSeconds() {
			return ProductHighlightedTiming(startTime: start, endTime: end)
		}
		return nil
	}
}

public extension String {
	func toSeconds() -> Int? {
		let timeComponents = components(separatedBy: ":")
		if timeComponents.count == 3 {
			let hours = Int(timeComponents[0]) ?? 0
			let minutes = Int(timeComponents[1]) ?? 0
			let seconds = Int(timeComponents[2]) ?? 0
			return hours*3600 + minutes*60 + seconds
		}
		return nil
	}
}

extension JSONProductResult {
	func toProduct() -> Product {
		return Product(
			id: id,
			title: product.title,
			price: product.price,
			detail: product.description,
			image: URL(string: product.image.src),
			link: URL(string: product.store_url),
			highlightTimings: highlight_timings?.compactMap { $0.toProductHighlightedTiming() })
	}
}
