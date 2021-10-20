//
//  LiveStreamRepository.swift
//  
//
//  Created by Sacha on 26/07/2020.
//

import Foundation
import Combine

public protocol LiveStreamRepository {
	func fetch(liveStream: LiveStream) -> AnyPublisher<LiveStream, Error>
	func getLiveStreams() -> AnyPublisher<[LiveStream], Error>
	func fetchEpisodes(for date: Date) -> AnyPaginator<LiveStream>
	func fetchEpisodes(for date: Date, daysAhead: Int?) -> AnyPaginator<LiveStream>
	func registerForRealTimeLiveStreamUpdates() -> AnyPublisher<LiveStreamStatusUpdate, Never>
	func leaveRealTimeLiveStreamUpdates()
	func fetchBroadcastUrl(for liveStream: LiveStream) -> AnyPublisher<LiveStream, Error>
	func getCurrentLiveStream() -> AnyPublisher<LiveStream?, Error>
	func getCurrentLiveStream(from showId: String) -> AnyPublisher<LiveStream?, Error>
	func fetchLiveStream(liveStreamId: String) -> AnyPublisher<LiveStream, Error>
	func fetchShowPublic(showId: String) -> AnyPublisher<Show, Error>
	
	// Subscriptions
	func registerDevice(token: String) -> AnyPublisher<Void, Error>
	func subscribe(to liveStream: LiveStream) -> AnyPublisher<Void, Error>
	func unSubscribe(from liveStream: LiveStream) -> AnyPublisher<Void, Error>
}
