//
//  SDKPlayerViewModel.swift
//  
//
//  Created by Sacha on 02/03/2021.
//

import Foundation
import Combine
import Live

final class SDKPlayerViewModel: ObservableObject {

	enum State {
		case loading
		case noEpisode
		case episode(Episode)
		case show(Show)
		case error(Error)
	}

	private var cancellables = Set<AnyCancellable>()
	
	@Published var episode: Episode?

	@Published var state = State.loading {
		didSet {
			if case let .episode(episode) = state {
				fetchBroadcastURL(episode: episode)
			}
		}
	}
    
	init(showId: String?) {
		load(showId: showId)
	}
	
	deinit {
		Live.shared.api.leaveEpisodeUpdates()
	}

	private func load(showId: String?) {
		if let showId = showId {
			loadSpecificShow(showId: showId)
		} else {
			loadAnyEpisode()
		}
	}

	private func loadAnyEpisode() {
		state = .loading
		Live.shared.api.authenticateAsGuest().flatMap { [unowned self] () -> AnyPublisher<Episode?, Error>  in
			self.registerForEpisodeUpdates()
			return Live.shared.api.fetchCurrentEpisode()
		}.map { [unowned self] currentEpisode in
			if let episode = currentEpisode {
				state = .episode(episode)
			} else {
				state = .noEpisode
			}
		}
		.mapError { [unowned self] (error: Publishers.FlatMap<AnyPublisher<Episode?, Error>, AnyPublisher<(), Error>>.Failure) -> Error in
			state = .error(error)
			return error
		}
		.sink()
		.store(in: &cancellables)
	}

	private func loadSpecificShow(showId: String) {
		state = .loading
		Live.shared.api.authenticateAsGuest().flatMap { [unowned self] () -> AnyPublisher<Episode?, Error>  in
			self.registerForEpisodeUpdates()
			return Live.shared.api.fetchCurrentEpisode(from: showId)
		}.map { [unowned self] currentEpisode in
			if let episode = currentEpisode {
				state = .episode(episode)
			} else {
				// Try to Load show
				Live.shared.api.fetchShowPublic(showId: showId).map { show in
					state = .show(show)
				}.mapError { e -> Error in
					print(e)
					state = .error(e)
					return e
				}
				.sink()
				.store(in: &cancellables)
			}
		}.eraseToAnyPublisher()
		.mapError { [unowned self] (error: Publishers.FlatMap<AnyPublisher<Episode?, Error>, AnyPublisher<(), Error>>.Failure) -> Error in
			state = .error(error)
			return error
		}
		.sink()
		.store(in: &cancellables)
	}

	private func fetchBroadcastURL(episode: Episode) {
		Live.shared.api.fetchBroadcastUrl(for: episode)
			.receive(on: RunLoop.main)
			.then { [unowned self] fetchedEpisode in
				self.episode = fetchedEpisode
			}
			.sink()
			.store(in: &cancellables)
	}

	private func registerForEpisodeUpdates() {
		Live.shared.api.registerForEpisodeUpdates()
			.ignoreError()
			.receive(on: RunLoop.main)
			.sink { [unowned self] update in
				if let episode = self.episode, update.id == episode.id {
					self.episode?.waitingRomDescription = update.waitingRoomDescription
					self.episode?.status = update.status
					if update.status == .broadcasting { // Fetch broadcastURL
						self.fetchBroadcastURL(episode: episode)
					}
				}
			}.store(in: &cancellables)
	}
}
