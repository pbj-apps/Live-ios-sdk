//
//  JSONPreviewAsset.swift
//  
//
//  Created by Sacha DSO on 27/11/2021.
//

import Foundation

struct JSONPreviewAsset: Decodable {

	let asset_url: String
	let asset_type: String
	let image: JSONPreviewAssetImage

	struct JSONPreviewAssetImage: Decodable {
		let small: String
		let medium: String
		let full_size: String
	}
}
