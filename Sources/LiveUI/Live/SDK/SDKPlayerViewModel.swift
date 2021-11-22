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
		case noLiveStream
		case liveStream(LiveStream)
		case show(Show)
		case error(Error)
	}

	private var cancellables = Set<AnyCancellable>()
	
	@Published var liveStream: LiveStream?

	@Published var state = State.loading {
		didSet {
			if case let .liveStream(liveStream) = state {

				fetchBroadcastURL(liveStream: liveStream)
			}
		}
	}
    
	init(showId: String?) {
		load(showId: showId)
	}
	
	deinit {
		Live.shared.api.leaveRealTimeLiveStreamUpdates()
	}

	private func load(showId: String?) {
		if let showId = showId {
			loadSpecificShow(showId: showId)
		} else {
			loadAnyLiveStream()
		}
	}

	private func loadAnyLiveStream() {
		state = .loading
		Live.shared.api.authenticateAsGuest().flatMap { [unowned self] () -> AnyPublisher<LiveStream?, Error>  in
			self.registerForRealTimeLiveStreamUpdates()
			return Live.shared.api.getCurrentLiveStream()
		}.map { [unowned self] currentLiveStream in
			if let liveStream = currentLiveStream {
				state = .liveStream(liveStream)
			} else {
				state = .noLiveStream
			}
		}
		.mapError { [unowned self] (error: Publishers.FlatMap<AnyPublisher<LiveStream?, Error>, AnyPublisher<(), Error>>.Failure) -> Error in
			state = .error(error)
			return error
		}
		.sink()
		.store(in: &cancellables)
	}

	private func loadSpecificShow(showId: String) {
		state = .loading
		Live.shared.api.authenticateAsGuest().flatMap { [unowned self] () -> AnyPublisher<LiveStream?, Error>  in
			self.registerForRealTimeLiveStreamUpdates()
			return Live.shared.api.getCurrentLiveStream(from: showId)
		}.map { [unowned self] currentLiveStream in
			if let liveStream = currentLiveStream {
				state = .liveStream(liveStream)
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
		.mapError { [unowned self] (error: Publishers.FlatMap<AnyPublisher<LiveStream?, Error>, AnyPublisher<(), Error>>.Failure) -> Error in
			state = .error(error)
			return error
		}
		.sink()
		.store(in: &cancellables)
	}

	private func fetchBroadcastURL(liveStream: LiveStream) {
		Live.shared.api.fetchBroadcastUrl(for: liveStream)
			.receive(on: RunLoop.main)
			.then { [unowned self] fetchedLiveStream in
				self.liveStream = fetchedLiveStream
			}
			.sink()
			.store(in: &cancellables)
	}

	private func registerForRealTimeLiveStreamUpdates() {
		Live.shared.api.registerForRealTimeLiveStreamUpdates()
			.ignoreError()
			.receive(on: RunLoop.main)
			.sink { [unowned self] update in
				if let liveStream = self.liveStream, update.id == liveStream.id {
					self.liveStream?.waitingRomDescription = update.waitingRoomDescription
					self.liveStream?.status = update.status
					if update.status == .broadcasting { // Fetch broadcastURL
						self.fetchBroadcastURL(liveStream: liveStream)
					}
				}
			}.store(in: &cancellables)
	}
}
