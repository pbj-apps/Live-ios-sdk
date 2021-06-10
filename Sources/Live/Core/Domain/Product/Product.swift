//
//  Product.swift
//  
//
//  Created by Sacha on 03/03/2021.
//

import Foundation

public struct Product: Equatable {
	public let id: String
	public let title: String
	public let price: String
	public let detail: String
	public let image: URL?
	public let link: URL?
	public let highlightTimings: [ProductHighlightedTiming]?
}

public struct ProductHighlightedTiming: Equatable {
	public let startTime: Int
	public let endTime: Int
}
