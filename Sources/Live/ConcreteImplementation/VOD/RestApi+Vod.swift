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

	public func fetchVodCategories() -> AnyPublisher<[VodCategory], Error> {
		return get("/vod/categories").map { (jsonVodCategoryPage: JSONPage<JSONVodCategory>) in
			jsonVodCategoryPage.results.map { $0.toVodCategory() }
		}.eraseToAnyPublisher()
	}

	public func fetch(category: VodCategory) -> AnyPublisher<VodCategory, Error> {
		return get("/vod/categories/\(category.id)").map { (jsonVodCategory: JSONVodCategory) in
			jsonVodCategory.toVodCategory()
		}.eraseToAnyPublisher()
	}
	
	public func fetchVodPlaylists() -> AnyPublisher<[VodPlaylist], Error> {
		return get("/vod/playlists").map { (page: JSONPage<JSONVodPlaylist>) in
			page.results.map { $0.playlist }
		}
		.eraseToAnyPublisher()
	}

	public func fetch(playlist: VodPlaylist) -> AnyPublisher<VodPlaylist, Error> {
		return get("/vod/playlists/\(playlist.id)").map { (jsonPlaylist: JSONVodPlaylist) in
			jsonPlaylist.playlist
		}
		.eraseToAnyPublisher()
	}
	
	public func fetchVodVideos() -> AnyPublisher<[VodVideo], Error> {
		return get("/vod/videos").map { (page: JSONPage<JSONVodVideo>) in
			page.results.map { $0.video }
		}
		.eraseToAnyPublisher()
	}

	public func fetch(video: VodVideo) -> AnyPublisher<VodVideo, Error> {
		return get("/vod/videos/\(video.id)").map { (jsonVideo: JSONVodVideo) in
			jsonVideo.video
		}
		.eraseToAnyPublisher()
	}

	public func searchVod(query: String) -> AnyPublisher<[VodItem], Error> {
		return get("/vod/items", params: ["search": query]).map { (page: JSONPage<JSONVodItem>) in
			page.results.map { $0.toVodItem() }
		}
		.eraseToAnyPublisher()
	}
	
	public func searchVodVideos(query: String) -> AnyPublisher<[VodVideo], Error> {
		return get("/vod/videos", params: ["search": query]).map { (page: JSONPage<JSONVodVideo>) in
			page.results.map { $0.video }
		}
		.eraseToAnyPublisher()
	}
}


extension JSONVodCategory: NetworkingJSONDecodable { }
extension JSONVodVideo:  NetworkingJSONDecodable { }
extension JSONVodPlaylist: NetworkingJSONDecodable { }
extension JSONPage: NetworkingJSONDecodable { }

