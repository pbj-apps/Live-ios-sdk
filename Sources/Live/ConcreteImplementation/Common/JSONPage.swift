//
//  JSONPage.swift
//  
//
//  Created by Sacha DSO on 27/11/2021.
//

import Foundation

struct JSONPage<T: Decodable>: Decodable {
	let count: Int
	let next: String?
	let results: [T]
}
