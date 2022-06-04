//
//  LiveRepository.swift
//  
//
//  Created by Sacha on 26/07/2020.
//

import Foundation
import Combine

public protocol LiveRepository {
	
	func fetch(episode: Episode) -> AnyPublisher<Episode, Error>
	func fetch(episode: Episode) async throws -> Episode
	
	func fetchEpisodes() -> AnyPublisher<[Episode], Error>
	func fetchEpisodes() async throws -> [Episode]
	
	func fetchEpisodes(for date: Date) -> AnyPaginator<Episode>
	func fetchEpisodes(for date: Date, daysAhead: Int?) -> AnyPaginator<Episode>
	func registerForEpisodeUpdates() -> AnyPublisher<EpisodeStatusUpdate, Error>
	func leaveEpisodeUpdates()
	
	func fetchBroadcastUrl(for episode: Episode) -> AnyPublisher<Episode, Error>
	func fetchBroadcastUrl(for episode: Episode) async throws -> Episode
	
	func fetchCurrentEpisode() -> AnyPublisher<Episode?, Error>
	func fetchCurrentEpisode() async throws -> Episode?
	
	func fetchCurrentEpisode(from showId: String) -> AnyPublisher<Episode?, Error>
	func fetchCurrentEpisode(from showId: String) async throws -> Episode?
	
	func fetchShowPublic(showId: String) -> AnyPublisher<Show, Error>
	func fetchShowPublic(showId: String) async throws -> Show
	
	
	// Subscriptions
	func registerDevice(token: String) -> AnyPublisher<Void, Error>
	func registerDevice(token: String) async throws
	
	func subscribe(to episode: Episode) -> AnyPublisher<Void, Error>
	func subscribe(to episode: Episode) async throws
	
	func unSubscribe(from episode: Episode) -> AnyPublisher<Void, Error>
	func unSubscribe(from episode: Episode) async throws
}
