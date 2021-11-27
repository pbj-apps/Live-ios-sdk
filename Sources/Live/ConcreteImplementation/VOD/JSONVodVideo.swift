//
//  JSONVodVideo.swift
//  
//
//  Created by Sacha DSO on 27/11/2021.
//

import Foundation

struct JSONVodVideo: Decodable {

	let video: VodVideo

	enum CodingKeys: String, CodingKey {
		case id
		case title
		case description
		case video_count
		case asset
		case preview_asset
		case duration
		case instructors
		case categories
		case playlists
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		let previewAsset = try values.decode(JSONPreviewAsset.self, forKey: .preview_asset)
		let asset = try values.decode(JSONPreviewAsset.self, forKey: .asset)
		let instructors = try? values.decode([JSONUser].self, forKey: .instructors)
		let categories = try? values.decode([JSONVodVideoCategory].self, forKey: .categories)
		let playlists = try? values.decode([JSONVodPlaylist].self, forKey: .playlists)
		video = VodVideo(id: try values.decode(String.self, forKey: .id),
										 title: try values.decode(String.self, forKey: .title),
										 description: try values.decode(String.self, forKey: .description),
										 isFeatured: false,
										 thumbnailImageUrl: URL(string: previewAsset.image.medium),
										 videoURL: URL(string: asset.asset_url),
										 duration: try? values.decode(Int.self, forKey: .duration),
										 instructors: instructors?.map { $0.toUser() } ?? [],
										 categories: categories?.map { $0.toCategory() } ?? [],
										 playlists: playlists?.map { $0.playlist } ?? [])
	}
}
