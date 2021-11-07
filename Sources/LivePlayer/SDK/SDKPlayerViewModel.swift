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
	var didTapClose: () -> Void = {}

	@Published var state = State.loading {
		didSet {
			if case let .liveStream(liveStream) = state {
				livePlayerViewModel = LivePlayerViewModel(liveStream: liveStream, productRepository: LiveSDK.shared.api)
				fetchBroadcastURL(liveStream: liveStream)
			}
		}
	}

	var livePlayerViewModel: LivePlayerViewModel? = nil

	func load(showId: String?) {
		if let showId = showId {
			loadSpecificShow(showId: showId)
		} else {
			loadAnyLiveStream()
		}
	}

	private func loadAnyLiveStream() {
		state = .loading
		LiveSDK.shared.api.authenticateAsGuest().flatMap { [unowned self] () -> AnyPublisher<LiveStream?, Error>  in
			self.registerForRealTimeLiveStreamUpdates()
			return LiveSDK.shared.api.getCurrentLiveStream()
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
		LiveSDK.shared.api.authenticateAsGuest().flatMap { [unowned self] () -> AnyPublisher<LiveStream?, Error>  in
			self.registerForRealTimeLiveStreamUpdates()
			return LiveSDK.shared.api.getCurrentLiveStream(from: showId)
		}.map { [unowned self] currentLiveStream in
			if let liveStream = currentLiveStream {
				state = .liveStream(liveStream)
			} else {
				// Try to Load show
				LiveSDK.shared.api.fetchShowPublic(showId: showId).map { show in
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
		LiveSDK.shared.api.fetchBroadcastUrl(for: liveStream)
			.receive(on: RunLoop.main)
			.then { [unowned self] fetchedLiveStream in
				self.livePlayerViewModel?.liveStream = fetchedLiveStream
			}
			.sink()
			.store(in: &cancellables)
	}

	private func registerForRealTimeLiveStreamUpdates() {
		LiveSDK.shared.api.registerForRealTimeLiveStreamUpdates()
			.ignoreError()
			.receive(on: RunLoop.main)
			.sink { [unowned self] update in
				if let liveStream = self.livePlayerViewModel?.liveStream, update.id == liveStream.id {
					self.livePlayerViewModel?.liveStream.waitingRomDescription = update.waitingRoomDescription
					self.livePlayerViewModel?.liveStream.status = update.status
					if update.status == .broadcasting { // Fetch broadcastURL
						self.fetchBroadcastURL(liveStream: liveStream)
					}
				}
			}.store(in: &cancellables)
	}
}
