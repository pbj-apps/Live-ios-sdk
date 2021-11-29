//
//  JSONShow.swift
//  
//
//  Created by Sacha on 01/03/2021.
//

import Foundation

struct JSONShow: Decodable {
	let title: String
	let description: String
	let preview_asset: JSONPreviewAsset?
}

extension JSONShow {
	func toShow() -> Show {

		return Show(
			title: title,
			description: description,
			previewImageUrl: preview_asset?.image.medium,
			previewVideoUrl: preview_asset?.asset_type == "video" ? preview_asset?.asset_url : nil
		)
	}
}
