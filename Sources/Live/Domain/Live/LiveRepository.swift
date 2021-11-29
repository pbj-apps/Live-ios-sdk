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
	func fetchEpisodes() -> AnyPublisher<[Episode], Error>
	func fetchEpisodes(for date: Date) -> AnyPaginator<Episode>
	func fetchEpisodes(for date: Date, daysAhead: Int?) -> AnyPaginator<Episode>
	func registerForEpisodeUpdates() -> AnyPublisher<EpisodeStatusUpdate, Error>
	func leaveEpisodeUpdates()
	func fetchBroadcastUrl(for episode: Episode) -> AnyPublisher<Episode, Error>
	func fetchCurrentEpisode() -> AnyPublisher<Episode?, Error>
	func fetchCurrentEpisode(from showId: String) -> AnyPublisher<Episode?, Error>
	func fetchShowPublic(showId: String) -> AnyPublisher<Show, Error>
	
	// Subscriptions
	func registerDevice(token: String) -> AnyPublisher<Void, Error>
	func subscribe(to episode: Episode) -> AnyPublisher<Void, Error>
	func unSubscribe(from episode: Episode) -> AnyPublisher<Void, Error>
}
