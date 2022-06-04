//
//  JSONVodPlaylist.swift
//  
//
//  Created by Sacha DSO on 27/11/2021.
//

import Foundation

struct JSONVodPlaylist: Decodable {

	let playlist: VodPlaylist

	enum CodingKeys: String, CodingKey {
		case id
		case title
		case description
		case video_count
		case videos
		case preview_asset
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		let id = try values.decode(String.self, forKey: .id)
		let title = try values.decode(String.self, forKey: .title)
		let description = try? values.decode(String.self, forKey: .description)
		let videoCount = try? values.decode(Int.self, forKey: .video_count)
		let previewAsset = try? values.decode(JSONPreviewAsset.self, forKey: .preview_asset)
		let jsonVideos: [JSONVodVideo] = (try? values.decode([JSONVodVideo].self, forKey: .videos)) ?? []
		playlist = VodPlaylist(id: id,
													 title: title,
													 description: description ?? "",
													 isFeatured: false,
													 thumbnailImageUrl: (previewAsset == nil) ? nil : URL(string: previewAsset!.image.medium),
													 videos: jsonVideos.map { $0.video },
													 videoCount: videoCount ?? 0)
	}
}
