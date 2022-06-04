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
	func fetchVodCategories() async throws -> [VodCategory]
	
	func fetch(category: VodCategory) -> AnyPublisher<VodCategory, Error>
	func fetch(category: VodCategory) async throws -> VodCategory
	
	func fetch(playlist: VodPlaylist) -> AnyPublisher<VodPlaylist, Error>
	func fetch(playlist: VodPlaylist) async throws -> VodPlaylist
	
	func fetch(video: VodVideo) -> AnyPublisher<VodVideo, Error>
	func fetch(video: VodVideo) async throws -> VodVideo
	
	func searchVod(query: String) -> AnyPublisher<[VodItem], Error>
	func searchVod(query: String) async throws -> [VodItem]
	
	func fetchVodPlaylists() -> AnyPublisher<[VodPlaylist], Error>
	func fetchVodPlaylists() async throws -> [VodPlaylist]
	
	func fetchVodVideos() -> AnyPublisher<[VodVideo], Error>
	func fetchVodVideos() async throws -> [VodVideo]

	func searchVodVideos(query: String) -> AnyPublisher<[VodVideo], Error>
	func searchVodVideos(query: String) async throws -> [VodVideo]
}
