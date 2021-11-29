//
//  VodRepository.swift
//  
//
//  Created by Sacha on 24/07/2020.
//

import Foundation
import Combine

public protocol VodRepository {
	func fetchVodCategories() -> AnyPublisher<[VodCategory], Error>
	func fetch(category: VodCategory) -> AnyPublisher<VodCategory, Error>
	func fetch(playlist: VodPlaylist) -> AnyPublisher<VodPlaylist, Error>
	func fetch(video: VodVideo) -> AnyPublisher<VodVideo, Error>
	func searchVod(query: String) -> AnyPublisher<[VodItem], Error>
	func fetchVodPlaylists() -> AnyPublisher<[VodPlaylist], Error>
	func fetchVodVideos() -> AnyPublisher<[VodVideo], Error>
	func searchVodVideos(query: String) -> AnyPublisher<[VodVideo], Error>
}
