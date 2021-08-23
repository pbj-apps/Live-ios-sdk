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



	public func fetchEpisodes(for date: Date) -> AnyPaginator<LiveStream> {
		/// For today's episodes, use the time of day to get the latest episode as fast as possible (and we don't need previous episodes.
		/// For next days, use a 00:00:00 time so as to get all the episode availables.
		var dateString = ""
		if date.isSameDay(as: Date()) {
			let secondsFromGMT = TimeZone.current.secondsFromGMT(for: date)
			let timeZoneOffsetDate = date.addingTimeInterval(-TimeInterval(secondsFromGMT))
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
			dateString = formatter.string(from: timeZoneOffsetDate)
		} else {
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd"
			dateString = formatter.string(from: date) + "T00:00:00"
		}
		let paginator = RestApiPaginator<JSONLiveStream, LiveStream>(baseUrl: baseUrl,
																																 "/v1/episodes?starting_at=\(dateString)",
																																 client: network, mapping: { $0.toLiveStream() })
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
			let streamType = response.stream_type
			var newLiveStream = liveStream

			// BroadcastUrl
			if streamType == nil || streamType == "live_stream" {
				if liveStream.vodId == nil && !response.broadcast_url.isEmpty {
					newLiveStream.broadcastUrl = response.broadcast_url
				}
			}

			// Elapsed time
			if streamType == nil || streamType == "pre_recorded_live_stream" {
				if let elapsed_time = response.elapsed_time,
					 let time = elapsed_time.split(separator: ".").first,
					 let timeInt = String(time).toSeconds() {
					newLiveStream.elapsedTime = TimeInterval(Float(timeInt))
					newLiveStream.elapsedTimeDate = Date()
				}
			}

			return newLiveStream
		}
		.eraseToAnyPublisher()
	}

	public func registerDevice(token: String) -> AnyPublisher<Void, Error> {
		return post("/device-registration-tokens", params: ["token" : token])
			.map { () -> Void in }
			.eraseToAnyPublisher()
	}

	public func subscribe(to liveStream: LiveStream) -> AnyPublisher<Void, Error> {
		let params: [String: CustomStringConvertible] = [
			"topic_type": "episode",
			"topic_id": liveStream.id
		]
		return post("/push-notifications/subscribe", params: params)
			.map { () -> Void in }
			.eraseToAnyPublisher()
	}

	public func unSubscribe(from liveStream: LiveStream) -> AnyPublisher<Void, Error> {
		let params: [String: CustomStringConvertible] = [
			"topic_type": "episode",
			"topic_id": liveStream.id
		]
		return post("/push-notifications/unsubscribe", params: params)
			.map { () -> Void in }
			.eraseToAnyPublisher()
	}
}

struct WatchJSONResponse: Decodable, NetworkingJSONDecodable {
	let stream_type: String?
	let broadcast_url: String
	let elapsed_time: String?
}

extension JSONLiveStream: NetworkingJSONDecodable {}
extension JSONShow: NetworkingJSONDecodable {}

private extension Date {
	func isSameDay(as date: Date) -> Bool {
		var calender = Calendar.current
		calender.timeZone = TimeZone.current
		let result = calender.compare(self, to: date, toGranularity: .day)
		return result == .orderedSame
	}
}
