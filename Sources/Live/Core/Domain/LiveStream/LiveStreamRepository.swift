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
	func fetchEpisodes(for: Date) -> AnyPaginator<LiveStream>
	func registerForRealTimeLiveStreamUpdates() -> AnyPublisher<LiveStreamStatusUpdate, Never>
	func leaveRealTimeLiveStreamUpdates()
	func fetchBroadcastUrl(for liveStream: LiveStream) -> AnyPublisher<LiveStream, Error>

	// Subscriptions
	func subscriptions() -> AnyPublisher<[String], Error>
	func subscribe(to liveStream: LiveStream, with token: String) -> AnyPublisher<Void, Error>
	func unSubscribe(from liveStream: LiveStream, with token: String) -> AnyPublisher<Void, Error>
}
