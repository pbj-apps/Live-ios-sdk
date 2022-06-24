//
//  JSONVodItem.swift
//  
//
//  Created by Sacha DSO on 27/11/2021.
//

import Foundation

public struct JSONVodItem: Decodable {
	let id: String
	let title: String
	let description: String
	let thumbnailImageUrl: String
	let isFeatured: Bool
	let itemType: JSONVodItemType
	let videoCount: Int?
	let videoUrl: String?
	let duration: Int?

	enum CodingKeys: String, CodingKey {
		case is_featured
		case item_type
		case item
	}

	enum ItemKeys: String, CodingKey {
		case id
		case title
		case description
		case asset
		case preview_asset
		case video_count
		case duration
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		isFeatured = try values.decode(Bool.self, forKey: .is_featured)
		itemType = try values.decode(JSONVodItemType.self, forKey: .item_type)
		let itemValues = try values.nestedContainer(keyedBy: ItemKeys.self, forKey: .item)
		id = try itemValues.decode(String.self, forKey: .id)
		title = try itemValues.decode(String.self, forKey: .title)
		description = try itemValues.decode(String.self, forKey: .description)
		duration = try? itemValues.decode(Int.self, forKey: .duration)

		if itemType == .playlist {
			let previewAsset = try itemValues.decode(JSONPreviewAsset.self, forKey: .preview_asset)
			thumbnailImageUrl = previewAsset.image.medium
			videoUrl = nil
			videoCount = try itemValues.decode(Int.self, forKey: .video_count)
		} else {
			let asset = try itemValues.decode(JSONPreviewAsset.self, forKey: .asset)
			let previewAsset = try itemValues.decode(JSONPreviewAsset.self, forKey: .preview_asset)
			thumbnailImageUrl = previewAsset.image.medium
			videoUrl = asset.asset_url
			videoCount = nil
		}
	}
}

public extension JSONVodItem {
	func toVodItem() -> VodItem {
		switch itemType {
		case .video:
			return VodItem(type: .video(VodVideo(id: id,
                                                title: title,
                                                description: description,
                                                isFeatured: isFeatured,
                                                thumbnailImageUrl: URL(string: thumbnailImageUrl),
                                                images: nil,
                                                videoURL: URL(string: videoUrl!),
                                                duration: duration,
                                                instructors: [])))
		case .playlist:
			return VodItem(type: .playlist(VodPlaylist(id: id,
                                                       title: title,
                                                       description: description,
                                                       isFeatured: isFeatured,
                                                       thumbnailImageUrl: URL(string: thumbnailImageUrl),
                                                       videos: [],
                                                       videoCount: videoCount!)))
		}
	}
}
