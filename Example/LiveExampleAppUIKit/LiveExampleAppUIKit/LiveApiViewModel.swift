//
//  LiveApiViewModel.swift
//  SachasPotatoes
//
//  Created by Sacha DSO on 19/11/2021.
//

import Foundation
import Live
import Combine

@MainActor
class LiveApiViewModel: ObservableObject {
	
	@Published var apiKey: String = "pk_l1t4P9eEPvLkpQBYMJirItrffN4JSAqUstJtb8BfWN4Eqr8U3bSvaQnE8JwH9rhHJmpnSBVWM3Q34BNvP8nUXln9k0I927op1ptSnU1hHRpOVYZayRNWEiNSxB0NgPEwRmFmy6ULnBYM6u1ymmn"
	@Published var environment: ApiEnvironment = .dev
	@Published var isInitialized = false
	@Published var command = ""
	@Published var response = ""
	@Published var realTimeUpdates = ""
	@Published var showsLivePlayer: Bool = false
	@Published var showsVodPlayer: Bool = false
	@Published var vodCategoryId: String = ""
	@Published var vodVideo: VodVideo?
	@Published var vodVideoId: String = ""
	@Published var vodPlaylist: VodPlaylist?
	@Published var vodPlaylistId: String = ""
	@Published var searchTerm: String = ""
	@Published var episode: Episode?
	@Published var liveEpisodeId: String = ""
	
	private var cancellables = Set<AnyCancellable>()
	
	var live: Live!
	
	func initialize() {
		live = LiveSDK.initialize(apiKey: apiKey, environment: environment, logLevels: .debug)
		
		live.authenticateAsGuest()
			.sink()
			.store(in: &cancellables)
		
		command = """
		let live = LiveSDK.initialize(apiKey: \"\(apiKey)\", environment: .\(environment.wording), completion: {
					// authenticated !
		})
		"""
		isInitialized = true
	}
    
	func fetchVodCategories() async throws {
		let categories = try await live.fetchVodCategories()
		response = "\(categories)"
		vodCategoryId = categories.first?.id ?? ""
		
		command = """
		live.fetchVodCategories()
		"""
	}
	
	func fetch(category: VodCategory) async throws {
		let category = try await live.fetch(category: category)
		response = "\(category)"
		vodCategoryId = category.id
		
		command = """
		live.fetch(category: category)
		"""
	}
	
	func fetchVodVideos() async throws {
		let videos = try await live.fetchVodVideos()
		response = "\(videos)"
		vodVideo = videos.first
		vodVideoId = videos.first?.id ?? ""
		
		command = """
		live.fetchAllVodVideos()
		"""
	}
	
	func fetch(video: VodVideo) async throws {
		let fetchedVideo = try await live.fetch(video: video)
		response = "\(fetchedVideo)"
		vodVideo = fetchedVideo
		vodVideoId = fetchedVideo.id
		
		command = """
		live.fetch(video: video)
		"""
	}
	
	func searchVodVideos(query: String) async throws {
		let videos = try await live.searchVodVideos(query: query)
		response = "\(videos)"
		vodVideo = videos.first
		vodVideoId = videos.first?.id ?? ""

		command = """
		live.searchVodVideos(query: query)
		"""
	}
	
	func searchVod(query: String) async throws {
		let vodItems = try await live.searchVod(query: query)
		response = "\(vodItems)"
		command = """
		live.searchVod(query: query)
		"""
	}
	
	func fetchVodPlaylists() async throws {
		let playlists = try await live.fetchVodPlaylists()
		response = "\(playlists)"
		vodPlaylist = playlists.first
		vodPlaylistId = playlists.first?.id ?? ""
		
		command = """
		live.fetchVodPlaylists()
		"""
	}
	
	func fetch(playlist: VodPlaylist) async throws {
		let fetchedPlaylist = try await live.fetch(playlist: playlist)
		response = "\(fetchedPlaylist)"
		vodPlaylist = fetchedPlaylist
		vodPlaylistId = fetchedPlaylist.id
		
		command = """
		live.fetch(playlist: playlist)
		"""
	}
	
	func fetchEpisodes() async throws {
		let episodes = try await live.fetchEpisodes()
		response = "\(episodes)"
		liveEpisodeId = episodes.first?.id ?? ""
		episode = episodes.last
		
		command = """
		live.fetchEpisodes()
		"""
	}
	
	func fetchCurrentEpisode() async throws {
		let fetchedEpisode = try await live.fetchCurrentEpisode()
		response = "\(fetchedEpisode)"
		liveEpisodeId = fetchedEpisode?.id ?? ""
		episode = fetchedEpisode

		command = """
		live.fetchCurrentEpisode()
		"""
	}
	
	func fetch(episode: Episode) async throws {
		let fetchedEpisode = try await live.fetch(episode: episode)
		response = "\(fetchedEpisode)"
		liveEpisodeId = fetchedEpisode.id
		self.episode = fetchedEpisode
		
		command = """
		live.fetch(episode: episode)
		"""
	}
	
	func registerForEpisodeUpdates() {
		live.registerForEpisodeUpdates()
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
				print(completion)
			}, receiveValue: { [weak self] update in
				self?.realTimeUpdates = "\(update)"
			})
			.store(in: &cancellables)
		
		command = """
		live.registerForEpisodeUpdates()
		"""
	}
	
	func leaveEpisodeUpdates() {
		live.leaveEpisodeUpdates()
		command = """
		live.leaveEpisodeUpdates()
		"""
	}
}


public extension Publisher {
	func sink(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
		return sink(receiveCompletion: { _ in }, receiveValue: receiveValue)
	}
}
