//
//  JSONVodVideoCategory.swift
//  
//
//  Created by Sacha DSO on 27/11/2021.
//

import Foundation

struct JSONVodVideoCategory: Decodable {
	let id: String
	let title: String
	let description: String

	func toCategory() -> VodCategory {
		return VodCategory(id: id, title: title, items: [])
	}
}
