//
//  JSONVodCategory.swift
//  
//
//  Created by Sacha DSO on 27/11/2021.
//

import Foundation

struct JSONVodCategory: Decodable {
	let id: String
	let title: String
	var items: [JSONVodItem]
}

extension JSONVodCategory {
	func toVodCategory() -> VodCategory {
		return VodCategory(id: id, title: title, items: items.map { $0.toVodItem() })
	}
}
