//
//  JSONPage.swift
//  
//
//  Created by Sacha DSO on 27/11/2021.
//

import Foundation

public struct JSONPage<T: Decodable>: Decodable {
	let count: Int
	let next: String?
	public let results: [T]
}
