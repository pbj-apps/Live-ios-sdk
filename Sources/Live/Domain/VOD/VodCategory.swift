//
//  VodCategory.swift
//  
//
//  Created by Sacha on 02/08/2020.
//

import Foundation

public struct VodCategory: Identifiable, Hashable, Equatable {
	public var id: String
	public let title: String
	public let items: [VodItem]

	public init(id: String, title: String, items: [VodItem]) {
		self.id = id
		self.title = title
		self.items = items
	}
	
	public init(id: String) {
		self.id = id
		self.title = ""
		self.items = []
	}
	
}
