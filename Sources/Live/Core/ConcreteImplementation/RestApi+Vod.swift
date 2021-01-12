//
//  RestApi+Vod.swift
//  
//
//  Created by Sacha on 24/07/2020.
//

import Foundation
import Combine
import Networking

extension RestApi: VodRepository {

	public func getVodCategories() -> AnyPaginator<VodCategory> {
		return AnyPaginator(RestApiPaginator<JSONVodCategory, VodCategory>(baseUrl: baseUrl, "/vod/categories?items_per_category=10", client: network, mapping: { $0.toVodCategory() }))
	}

	public func getPlaylist(playlist: VodPlaylist) -> AnyPublisher<VodPlaylist, Error> {
		return get("/vod/playlists/\(playlist.id)").map { (jsonPlaylist: JSONVodPlaylist) in
			jsonPlaylist.playlist
		}
		.eraseToAnyPublisher()
	}

	public func fetch(video: VodVideo) -> AnyPublisher<VodVideo, Error> {
		return get("/vod/videos/\(video.id)").map { (jsonVideo: JSONVodVideo) in
			jsonVideo.video
		}
		.eraseToAnyPublisher()
	}
}

struct JSONVodVideo: Decodable, NetworkingJSONDecodable {

	let video: VodVideo

	enum CodingKeys: String, CodingKey {
		case id
		case title
		case description
		case video_count
		case asset
		case duration
		case instructors
		case categories
		case playlists
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		let asset = try values.decode(JSONPreviewAsset.self, forKey: .asset)
		let instructors = try? values.decode([JSONUser].self, forKey: .instructors)
		let categories = try? values.decode([JSONVodVideoCategory].self, forKey: .categories)
		let playlists = try? values.decode([JSONVodPlaylist].self, forKey: .playlists)
		video = VodVideo(id: try values.decode(String.self, forKey: .id),
										 title: try values.decode(String.self, forKey: .title),
										 description: try values.decode(String.self, forKey: .description),
										 isFeatured: false,
										 thumbnailImageUrl: URL(string: asset.image.medium),
										 videoURL: URL(string: asset.asset_url),
										 duration: try? values.decode(Int.self, forKey: .duration),
										 instructors: instructors?.map { $0.toUser() } ?? [],
										 categories: categories?.map { $0.toCategory() } ?? [],
										 playlists: playlists?.map { $0.playlist } ?? [])
	}
}

struct JSONVodVideoCategory: Decodable {
	let id: String
	let title: String
	let description: String

	func toCategory() -> VodCategory {
		return VodCategory(id: id, title: title, items: [])
	}
}

struct JSONVodPlaylist: Decodable, NetworkingJSONDecodable {

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

struct JSONPage<T: Decodable>: Decodable, NetworkingJSONDecodable {
	let count: Int
	let next: String?
	let results: [T]
}

struct JSONVodCategory: Decodable {
	let id: String
	let title: String
	var items: [JSONVodItem]
}

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

struct JSONVodItem: Decodable {
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

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		isFeatured = try values.decode(Bool.self, forKey: .is_featured)
		itemType = try values.decode(JSONVodItemType.self, forKey: .item_type)
		let itemValues = try values.nestedContainer(keyedBy: ItemKeys.self, forKey: .item)
		id = try itemValues.decode(String.self, forKey: .id)
		title = try itemValues.decode(String.self, forKey: .title)
		description = try itemValues.decode(String.self, forKey: .description)
		duration = try? itemValues.decode(Int.self, forKey: .duration)

		if itemType == .playlist {
			let asset = try itemValues.decode(JSONPreviewAsset.self, forKey: .preview_asset)
			thumbnailImageUrl = asset.image.medium
			videoUrl = nil
			videoCount = try itemValues.decode(Int.self, forKey: .video_count)
		} else {
			let asset = try itemValues.decode(JSONPreviewAsset.self, forKey: .asset)
			thumbnailImageUrl = asset.image.medium
			videoUrl = asset.asset_url
			videoCount = nil
		}
	}
}

extension JSONVodCategory {
	func toVodCategory() -> VodCategory {
		return VodCategory(id: id, title: title, items: items.map { $0.toVodItem() })
	}
}

extension JSONVodItem {
	func toVodItem() -> VodItem {
		switch itemType {
		case .video:
			return VodItem(type: .video(VodVideo(id: id,
																					 title: title,
																					 description: description,
																					 isFeatured: isFeatured,
																					 thumbnailImageUrl: URL(string: thumbnailImageUrl),
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

public enum JSONVodItemType: String, Codable {
	case video
	case playlist
}

private extension Error {
	func toApiError() -> APIError {
		return APIError.emptyResponse
	}
}

public enum APIError: Error {
	case emptyResponse
	case mappingError(error: DecodingError)
	case genericError(description: String)
	case remoteError(Error)
}

extension APIError {
	var localizedDescription: String {
		switch self {
		case .emptyResponse:
			return "Something went wrong"
		case let .genericError(description):
			return description
		case let .mappingError(error):
			return error.localizedDescription
		case let .remoteError(underlying):
			return underlying.localizedDescription
		}
	}

	var code: Int? {
		if case .remoteError(let underlying) = self {
			return (underlying as NSError).code
		}
		return nil
	}
}
