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
	let preview_image_url: String?
	let preview_video_url: String?
}

extension JSONShow {
	func toShow() -> Show {
		return Show(
			title: title,
			description: description,
			previewImageUrl: preview_image_url,
			previewVideoUrl: preview_video_url
		)
	}
}
