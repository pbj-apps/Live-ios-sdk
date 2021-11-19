//
//  LiveApi.swift
//  
//
//  Created by Sacha on 01/03/2021.
//

import Foundation
import Combine
import Live

public class Live {

	public static let shared = Live()
	internal var api: RestApi!
	private var cancellables = Set<AnyCancellable>()
	
	// MARK: - Initialization

	public func initialize(apiKey: String, environment: ApiEnvironment = .prod, completion: (() -> Void)? = nil) {
		api = RestApi(apiUrl: "https://\(environment.domain)/api",
									webSocketsUrl: "wss://\(environment.domain)/ws",
									apiKey: apiKey)
		api.authenticateAsGuest().then {
			completion?()
		}
		.sink()
		.store(in: &cancellables)
	}
	
	// MARK: - VoD
	
	public func fetchVodCategories() -> AnyPublisher<[VodCategory], Error> {
		api.getVodCategories()
	}
	
	public func fetch(category: VodCategory) -> AnyPublisher<VodCategory, Error> {
		api.fetch(category: category)
	}
	
	
	public func fetchVodVideos() -> AnyPublisher<[VodVideo], Error> {
		api.fetchVodVideos()
	}
	
	public func fetch(video: VodVideo) -> AnyPublisher<VodVideo, Error> {
		api.fetch(video: video)
	}
	
	public func searchVodVideos(query: String) -> AnyPublisher<[VodVideo], Error> {
		api.searchVodVideos(query: query)
	}
	
	public func fetchVodPlaylists() -> AnyPublisher<[VodPlaylist], Error> {
		api.fetchVodPlaylists()
	}
	
	public func fetch(playlist: VodPlaylist) -> AnyPublisher<VodPlaylist, Error> {
		api.fetch(playlist: playlist)
	}
	
	public func searchVod(query: String) -> AnyPublisher<[VodItem], Error> {
		api.searchVod(query: query)
	}
	
	// MARK: - Old Api
	
	public func isEpisodeLive() -> AnyPublisher<Bool, Error> {
		return api.authenticateAsGuest()
			.flatMap { self.api.getCurrentLiveStream() }
			.map { $0 != nil }
			.eraseToAnyPublisher()
	}
	
	public func isEpisodeLive(completion: @escaping (Bool, Error?) -> Void) {
		isEpisodeLive().sink { receiveCompletion in
			switch receiveCompletion {
			case .finished: ()
			case .failure(let error):
				completion(false, error)
			}
		} receiveValue: {
			completion($0, nil)
		}.store(in: &cancellables)
	}

	public func isEpisodeLive(forShowId showId: String) -> AnyPublisher<Bool, Error> {
		return api.authenticateAsGuest()
			.flatMap { self.api.getCurrentLiveStream(from: showId) }
			.map { $0 != nil }
			.eraseToAnyPublisher()
	}

	public func isEpisodeLive(forShowId showId: String, completion: @escaping (Bool, Error?) -> Void) {
		isEpisodeLive(forShowId: showId).sink { receiveCompletion in
			switch receiveCompletion {
			case .finished: ()
			case .failure(let error):
				completion(false, error)
			}
		} receiveValue: {
			completion($0, nil)
		}.store(in: &cancellables)
	}
}
