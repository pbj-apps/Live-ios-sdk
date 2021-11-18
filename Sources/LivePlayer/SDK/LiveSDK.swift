//
//  LiveSDK.swift
//  
//
//  Created by Sacha on 01/03/2021.
//

import Foundation
import Combine
import Live

public class LiveApi {

	public let restApi: RestApi
	public init(apiKey: String, environment: ApiEnvironment = .prod) {
		restApi = RestApi(apiUrl: "https://\(environment.domain)/api",
									webSocketsUrl: "wss://\(environment.domain)/ws",
									apiKey: apiKey)
	}
}

public extension LiveApi {
	
	public func getVodCategories() -> AnyPublisher<[VodCategory], Error> {
		restApi.getVodCategories()
	}
	
//	public func fetch(category: VodCategory) -> AnyPublisher<VodCategory, Error> {
//		<#code#>
//	}
//
//	public func getPlaylist(playlist: VodPlaylist) -> AnyPublisher<VodPlaylist, Error> {
//		<#code#>
//	}
//
//	public func fetch(video: VodVideo) -> AnyPublisher<VodVideo, Error> {
//		<#code#>
//	}
//
//	public func search(query: String) -> AnyPublisher<[VodItem], Error> {
//		<#code#>
//	}
	
}

public class LiveSDK {

	internal static let shared = LiveSDK()
	internal var api: RestApi!
	private var cancellables = Set<AnyCancellable>()

	public static func initialize(apiKey: String, environment: ApiEnvironment = .prod) {
		shared.api = RestApi(apiUrl: "https://\(environment.domain)/api",
												 webSocketsUrl: "wss://\(environment.domain)/ws", apiKey: apiKey)
	}

	public static func isEpisodeLive() -> AnyPublisher<Bool, Error> {
		return shared.api.authenticateAsGuest()
			.flatMap { shared.api.getCurrentLiveStream() }
			.map { $0 != nil }
			.eraseToAnyPublisher()
	}

	public static func isEpisodeLive(completion: @escaping (Bool, Error?) -> Void) {
		isEpisodeLive().sink { receiveCompletion in
			switch receiveCompletion {
			case .finished: ()
			case .failure(let error):
				completion(false, error)
			}
		} receiveValue: {
			completion($0, nil)
		}.store(in: &shared.cancellables)
	}

	public static func isEpisodeLive(forShowId showId: String) -> AnyPublisher<Bool, Error> {
		return shared.api.authenticateAsGuest()
			.flatMap { shared.api.getCurrentLiveStream(from: showId) }
			.map { $0 != nil }
			.eraseToAnyPublisher()
	}

	public static func isEpisodeLive(forShowId showId: String, completion: @escaping (Bool, Error?) -> Void) {
		isEpisodeLive(forShowId: showId).sink { receiveCompletion in
			switch receiveCompletion {
			case .finished: ()
			case .failure(let error):
				completion(false, error)
			}
		} receiveValue: {
			completion($0, nil)
		}.store(in: &shared.cancellables)
	}
}
