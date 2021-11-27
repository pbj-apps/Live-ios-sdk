//
//  LiveApiViewModel.swift
//  SachasPotatoes
//
//  Created by Sacha DSO on 19/11/2021.
//

import Foundation
import Live
import Combine

class LiveApiViewModel: ObservableObject {
	
	@Published var apiKey: String = "pk_l1t4P9eEPvLkpQBYMJirItrffN4JSAqUstJtb8BfWN4Eqr8U3bSvaQnE8JwH9rhHJmpnSBVWM3Q34BNvP8nUXln9k0I927op1ptSnU1hHRpOVYZayRNWEiNSxB0NgPEwRmFmy6ULnBYM6u1ymmn"
	@Published var environment: ApiEnvironment = .dev
	@Published var isInitialized = false
	@Published var command = ""
	@Published var response = ""
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
	
	func initialize() {
		Live.shared.initialize(apiKey: apiKey, environment: environment, completion: { [weak self] in
			self?.isInitialized = true
		})
		command = """
		Live.shared.initialize(apiKey: \"\(apiKey)\", environment: .\(environment.wording), completion: {
					// authenticated !
		})
		"""
		isInitialized = true
	}
	
	func fetchVodCategories() {
		Live.shared.fetchVodCategories().then { [weak self] categories in
			self?.response = "\(categories)"
			self?.vodCategoryId = categories.first?.id ?? ""
		}
		.sink()
		.store(in: &cancellables)

		command = """
		Live.shared.fetchVodCategories()
		"""
	}
	
	func fetch(category: VodCategory) {
		Live.shared.fetch(category: category).then { [weak self] category in
			self?.response = "\(category)"
			self?.vodCategoryId = category.id
		}
		.sink()
		.store(in: &cancellables)
		
		command = """
		Live.shared.fetch(category: category)
		"""
	}
	
	func fetchVodVideos() {
		Live.shared.fetchVodVideos().then { [weak self] videos in
			self?.response = "\(videos)"
			self?.vodVideo = videos.first
			self?.vodVideoId = videos.first?.id ?? ""
		}
		.sink()
		.store(in: &cancellables)
		
		command = """
		Live.shared.fetchAllVodVideos()
		"""
	}
	
	func fetch(video: VodVideo) {
		Live.shared.fetch(video: video).then { [weak self] fetchedVideo in
			self?.response = "\(fetchedVideo)"
			self?.vodVideo = fetchedVideo
			self?.vodVideoId = fetchedVideo.id
		}
		.sink()
		.store(in: &cancellables)
		
		command = """
		Live.shared.fetch(video: video)
		"""
	}
	
	func searchVodVideos(query: String) {
		Live.shared.searchVodVideos(query: query).then { [weak self] videos in
			self?.response = "\(videos)"
			self?.vodVideo = videos.first
			self?.vodVideoId = videos.first?.id ?? ""
		}
		.sink()
		.store(in: &cancellables)
		
		command = """
		Live.shared.searchVodVideos(query: query)
		"""
	}
	
	func searchVod(query: String) {
		Live.shared.searchVod(query: query).then { [weak self] vodItems in
			self?.response = "\(vodItems)"
		}
		.sink()
		.store(in: &cancellables)
		command = """
		Live.shared.searchVod(query: query)
		"""
	}
	
	func fetchVodPlaylists() {
		Live.shared.fetchVodPlaylists().then { [weak self] playlists in
			self?.response = "\(playlists)"
			self?.vodPlaylist = playlists.first
			self?.vodPlaylistId = playlists.first?.id ?? ""
		}
		.sink()
		.store(in: &cancellables)
		
		command = """
		Live.shared.fetchVodPlaylists()
		"""
	}
	
	func fetch(playlist: VodPlaylist) {
		Live.shared.fetch(playlist: playlist).then { [weak self] fetchedPlaylist in
			self?.response = "\(fetchedPlaylist)"
			self?.vodPlaylist = fetchedPlaylist
			self?.vodPlaylistId = fetchedPlaylist.id
		}
		.sink()
		.store(in: &cancellables)
		
		command = """
		Live.shared.fetch(playlist: playlist)
		"""
	}
	
	func fetchEpisodes() {
		Live.shared.fetchEpisodes().then { [weak self] episodes in
			self?.response = "\(episodes)"
			self?.liveEpisodeId = episodes.first?.id ?? ""
			self?.episode = episodes.last
		}
		.sink()
		.store(in: &cancellables)
		
		command = """
		Live.shared.fetchEpisodes()
		"""
	}
	
	func fetch(episode: Episode) {
		Live.shared.fetch(episode: episode).then { [weak self] episode in
			self?.response = "\(episode)"
			self?.episode = episode
		}
		.sink()
		.store(in: &cancellables)
		
		command = """
		Live.shared.fetch(episode: episode)
		"""
	}
}
