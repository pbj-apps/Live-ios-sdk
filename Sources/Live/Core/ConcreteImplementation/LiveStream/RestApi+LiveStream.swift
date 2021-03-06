//
//  RestApi+LiveStream.swift
//  
//
//  Created by Sacha on 27/07/2020.
//

import Foundation
import Combine
import Networking

extension RestApi: LiveStreamRepository {

	public func fetch(liveStream: LiveStream) -> AnyPublisher<LiveStream, Error> {
		return get("/live-streams/\(liveStream.id)").map { (jsonLivestream: JSONLiveStream) in
			return jsonLivestream.toLiveStream()
		}.eraseToAnyPublisher()
	}

	public func getLiveStreams() -> AnyPublisher<[LiveStream], Error> {
		return get("/live-streams").map { (page: JSONPage<JSONLiveStream>) in
			return page.results.map { $0.toLiveStream() }
		}.eraseToAnyPublisher()
	}

	public func getCurrentLiveStream() -> AnyPublisher<LiveStream?, Error> {
		return get("/episodes/current")
			.map { (page: JSONPage<JSONLiveStream>) in
				return page.results.map { $0.toLiveStream() }
			}
			.map { $0.first }
			.eraseToAnyPublisher()
	}

	public func getCurrentLiveStream(from showId: String) -> AnyPublisher<LiveStream?, Error> {
		return get("/episodes/current", params: ["show_id" : showId ])
			.map { (page: JSONPage<JSONLiveStream>) in
				return page.results.map { $0.toLiveStream() }
			}
			.map { $0.first }
			.eraseToAnyPublisher()
	}

	public func fetchLiveStream(liveStreamId: String) -> AnyPublisher<LiveStream, Error> {
		return get("/live-streams/\(liveStreamId)").map { (jsonLiveStream: JSONLiveStream) in
			return jsonLiveStream.toLiveStream()
		}.eraseToAnyPublisher()
	}

	public func fetchShowPublic(showId: String) -> AnyPublisher<Show, Error> {
		return get("/shows/\(showId)/public").map { (jsonShow: JSONShow) in
			return jsonShow.toShow()
		}.eraseToAnyPublisher()
	}

	public func getLiveStreamsSchedule() -> AnyPaginator<LiveStream> {
		let paginator = RestApiPaginator<JSONLiveStream, LiveStream>(baseUrl: baseUrl, "/live-streams/schedule?days_ahead=7", client: network, mapping: { $0.toLiveStream() })
		return AnyPaginator(paginator)
	}

	public func registerForRealTimeLiveStreamUpdates() -> AnyPublisher<LiveStreamStatusUpdate, Never> {
		webSocket.joinEpisodeUpdates()
	}

	public func leaveRealTimeLiveStreamUpdates() {
		webSocket.leaveEpisodeUpdates()
	}

	public func fetchBroadcastUrl(for liveStream: LiveStream) -> AnyPublisher<LiveStream, Error> {
		get("/live-streams/\(liveStream.id)/watch").map { (response: WatchJSONResponse) in
			var newLiveStream = liveStream

			if !response.broadcast_url.isEmpty {
				newLiveStream.broadcastUrl = response.broadcast_url
			}
			if let elapsed_time = response.elapsed_time,
				 let time = elapsed_time.split(separator: ".").first,
				 let timeInt = String(time).toSeconds() {
				newLiveStream.elapsedTime = TimeInterval(Float(timeInt))
				newLiveStream.elapsedTimeDate = Date()
			}
			return newLiveStream
		}
		.eraseToAnyPublisher()
	}

	public func subscriptions() -> AnyPublisher<[String], Error> {
		return get("/notifications/subscriptions")
			.map { (json: Any) -> [String] in
				if let dic = json as? [String: AnyHashable], let results = dic["results"] as? [[String: AnyHashable]] {
					return results.compactMap {
						$0["topic_id"] as? String
					}
				}
				return []
			}
			.eraseToAnyPublisher()
	}

	public func subscribe(to liveStream: LiveStream, with token: String) -> AnyPublisher<Void, Error> {
		let params: [String: CustomStringConvertible] = [
			"topic_type": "show",
			"topic_id": liveStream.showId,
			"device_registration_tokens": [token]
		]
		return post("/notifications/subscriptions", params: params)
			.map { () -> Void in }
			.eraseToAnyPublisher()
	}

	public func unSubscribe(from liveStream: LiveStream, with token: String) -> AnyPublisher<Void, Error> {
		let params: [String: CustomStringConvertible] = [
			"topic_type": "show",
			"topic_id": liveStream.showId,
			"device_registration_tokens": [token]
		]
		return delete("/notifications/subscriptions", params: params)
			.map { () -> Void in }
			.eraseToAnyPublisher()
	}
}

struct WatchJSONResponse: Decodable, NetworkingJSONDecodable {
	let broadcast_url: String
	let elapsed_time: String?
}

extension JSONLiveStream: NetworkingJSONDecodable {}
extension JSONShow: NetworkingJSONDecodable {}
