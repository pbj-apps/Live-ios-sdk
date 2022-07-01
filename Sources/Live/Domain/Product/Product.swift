//
//  Product.swift
//  
//
//  Created by Sacha on 03/03/2021.
//

import Foundation

public struct Product: Equatable, Identifiable {
	public let id: String
    public let externalId: String
	public let title: String
	public let price: String
	public let detail: String
	public let image: URL?
	public let link: URL?
	public let isHighlighted: Bool
	public let highlightTimings: [ProductHighlightedTiming]?

	public init(id: String,
                externalId: String,
                title: String,
                price: String,
                detail: String,
                image: URL?,
                link: URL?,
                isHighlighted: Bool,
                highlightTimings: [ProductHighlightedTiming]?){
		self.id = id
        self.externalId = externalId
		self.title = title
		self.price = price
		self.detail = detail
		self.image = image
		self.link = link
		self.isHighlighted = isHighlighted
		self.highlightTimings = highlightTimings
	}
}

public struct ProductHighlightedTiming: Equatable {
	public let startTime: Int
	public let endTime: Int
	
	public init(startTime: Int, endTime: Int) {
		self.startTime = startTime
		self.endTime = endTime
	}
}
