//
//  SDKPlayerViewModel.swift
//  
//
//  Created by Sacha on 02/03/2021.
//

import Foundation
import Combine

class SDKPlayerViewModel: ObservableObject {

	private var cancellables = Set<AnyCancellable>()
	var didTapClose: () -> Void = {}

	@Published var noLiveStream = false
	@Published var error: Error?
	@Published var isLoading = false
	@Published var show: Show? = nil
	@Published var liveStream: LiveStream? = nil {
		didSet {
			if let liveStream = liveStream {
				livePlayerViewModel = LivePlayerViewModel(liveStream: liveStream)
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
		isLoading = true
		LiveSDK.shared.api.authenticateAsGuest().flatMap { [unowned self] () -> AnyPublisher<LiveStream?, Error>  in
			self.registerForRealTimeLiveStreamUpdates()
			return LiveSDK.shared.api.getCurrentLiveStream()
		}.map { [unowned self] currentLiveStream in
				liveStream = currentLiveStream
		}
		.mapError { [unowned self] (error: Publishers.FlatMap<AnyPublisher<LiveStream?, Error>, AnyPublisher<(), Error>>.Failure) -> Error in
			self.error = error
			return error
		}.finally { [unowned self] in
			self.isLoading = false
		}
		.sink()
		.store(in: &cancellables)
	}

	private func loadSpecificShow(showId: String) {
		isLoading = true
		LiveSDK.shared.api.authenticateAsGuest().flatMap { [unowned self] () -> AnyPublisher<LiveStream?, Error>  in
			self.registerForRealTimeLiveStreamUpdates()
			return LiveSDK.shared.api.getCurrentLiveStream(from: showId)
		}.map { [unowned self] currentLiveStream in
			if let liveStream = currentLiveStream {
				self.liveStream = liveStream
			} else {
				// Try to Load show
				LiveSDK.shared.api.fetchShowPublic(showId: showId).map { show in
					self.show = show
					self.isLoading = false
				}.mapError { e -> Error in
					print(e)
					self.error = e
					self.isLoading = false
					return e
				}
				.sink()
				.store(in: &cancellables)
			}
		}.eraseToAnyPublisher()
		.mapError { [unowned self] (error: Publishers.FlatMap<AnyPublisher<LiveStream?, Error>, AnyPublisher<(), Error>>.Failure) -> Error in
			self.error = error
			self.isLoading = false
			return error
		}
		.sink()
		.store(in: &cancellables)
	}

	private func fetchBroadcastURL(liveStream: LiveStream) {
		LiveSDK.shared.api.fetchBroadcastUrl(for: liveStream)
			.receive(on: RunLoop.main)
			.then { [unowned self] broadcastURL in
				self.liveStream?.broadcastUrl = broadcastURL
				self.livePlayerViewModel?.liveStream.broadcastUrl = broadcastURL
			}
			.sink()
			.store(in: &cancellables)
	}

	private func registerForRealTimeLiveStreamUpdates() {
		LiveSDK.shared.api.registerForRealTimeLiveStreamUpdates()
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
