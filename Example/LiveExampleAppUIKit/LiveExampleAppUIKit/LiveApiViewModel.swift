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
	
	func fetchVodCategories() {
		live.fetchVodCategories().sink { [weak self] categories in
			self?.response = "\(categories)"
			self?.vodCategoryId = categories.first?.id ?? ""
		}
		.store(in: &cancellables)

		command = """
		live.fetchVodCategories()
		"""
	}
	
	func fetch(category: VodCategory) {
		live.fetch(category: category).sink { [weak self] category in
			self?.response = "\(category)"
			self?.vodCategoryId = category.id
		}
		.store(in: &cancellables)
		
		command = """
		live.fetch(category: category)
		"""
	}
	
	func fetchVodVideos() {
		live.fetchVodVideos().sink { [weak self] videos in
			self?.response = "\(videos)"
			self?.vodVideo = videos.first
			self?.vodVideoId = videos.first?.id ?? ""
		}
		.store(in: &cancellables)
		
		command = """
		Live.shared.fetchAllVodVideos()
		"""
	}
	
	func fetch(video: VodVideo) {
		live.fetch(video: video).sink { [weak self] fetchedVideo in
			self?.response = "\(fetchedVideo)"
			self?.vodVideo = fetchedVideo
			self?.vodVideoId = fetchedVideo.id
		}
		.store(in: &cancellables)
		
		command = """
		Live.shared.fetch(video: video)
		"""
	}
	
	func searchVodVideos(query: String) {
		live.searchVodVideos(query: query).sink { [weak self] videos in
			self?.response = "\(videos)"
			self?.vodVideo = videos.first
			self?.vodVideoId = videos.first?.id ?? ""
		}
		.store(in: &cancellables)
		
		command = """
		Live.shared.searchVodVideos(query: query)
		"""
	}
	
	func searchVod(query: String) {
		live.searchVod(query: query).sink { [weak self] vodItems in
			self?.response = "\(vodItems)"
		}
		.store(in: &cancellables)
		command = """
		Live.shared.searchVod(query: query)
		"""
	}
	
	func fetchVodPlaylists() {
		live.fetchVodPlaylists().sink { [weak self] playlists in
			self?.response = "\(playlists)"
			self?.vodPlaylist = playlists.first
			self?.vodPlaylistId = playlists.first?.id ?? ""
		}
		.store(in: &cancellables)
		
		command = """
		Live.shared.fetchVodPlaylists()
		"""
	}
	
	func fetch(playlist: VodPlaylist) {
		live.fetch(playlist: playlist).sink { [weak self] fetchedPlaylist in
			self?.response = "\(fetchedPlaylist)"
			self?.vodPlaylist = fetchedPlaylist
			self?.vodPlaylistId = fetchedPlaylist.id
		}
		.store(in: &cancellables)
		
		command = """
		Live.shared.fetch(playlist: playlist)
		"""
	}
	
	func fetchEpisodes() {
		live.fetchEpisodes().sink { [weak self] episodes in
			self?.response = "\(episodes)"
			self?.liveEpisodeId = episodes.first?.id ?? ""
			self?.episode = episodes.last
		}
		.store(in: &cancellables)
		
		command = """
		live.fetchEpisodes()
		"""
	}
	
	func fetchCurrentEpisode() {
		live.fetchCurrentEpisode().sink { [weak self] fetchedEpisode in
			self?.response = "\(fetchedEpisode)"
			self?.liveEpisodeId = fetchedEpisode?.id ?? ""
			self?.episode = fetchedEpisode
		}
		.store(in: &cancellables)
		
		command = """
		live.fetchCurrentEpisode()
		"""
	}
	
	func fetch(episode: Episode) {
		live.fetch(episode: episode).sink { [weak self] fetchedEpisode in
			self?.response = "\(fetchedEpisode)"
			self?.liveEpisodeId = fetchedEpisode.id
			self?.episode = fetchedEpisode
		}
		.store(in: &cancellables)
		
		command = """
		live.fetch(episode: episode)
		"""
	}
}


public extension Publisher {
	func sink(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
		return sink(receiveCompletion: { _ in }, receiveValue: receiveValue)
	}
}
