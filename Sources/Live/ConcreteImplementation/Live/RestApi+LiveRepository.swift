//
//  RestApi+LiveRepository.swift
//  
//
//  Created by Sacha on 27/07/2020.
//

import Foundation
import Combine
import Networking

extension RestApi: LiveRepository {
	
	public func fetchEpisodes() -> AnyPublisher<[Episode], Error> {
		return get("/v1/episodes").map { (page: JSONPage<JSONEpisode>) in
			return page.results.map { $0.toEpisode() }
		}.eraseToAnyPublisher()
	}

	public func fetchCurrentEpisode() -> AnyPublisher<Episode?, Error> {
		return get("/v1/episodes/current")
			.map { (page: JSONPage<JSONEpisode>) in
				return page.results.map { $0.toEpisode() }
			}
			.map { $0.first }
			.eraseToAnyPublisher()
	}

	public func fetchCurrentEpisode(from showId: String) -> AnyPublisher<Episode?, Error> {
		return get("/v1/episodes/current", params: ["show_id" : showId ])
			.map { (page: JSONPage<JSONEpisode>) in
				return page.results.map { $0.toEpisode() }
			}
			.map { $0.first }
			.eraseToAnyPublisher()
	}

	public func fetch(episode: Episode) -> AnyPublisher<Episode, Error> {
		return get("/v1/episodes/\(episode.id)").map { (jsonEpisode: JSONEpisode) in
			return jsonEpisode.toEpisode()
		}.eraseToAnyPublisher()
	}

	public func fetchShowPublic(showId: String) -> AnyPublisher<Show, Error> {
		return get("/shows/\(showId)/public").map { (jsonShow: JSONShow) in
			return jsonShow.toShow()
		}.eraseToAnyPublisher()
	}

	public func fetchEpisodes(for date: Date) -> AnyPaginator<Episode> {
		fetchEpisodes(for: date, daysAhead: nil)
	}

	public func fetchEpisodes(for date: Date, daysAhead: Int?) -> AnyPaginator<Episode> {
		/// For today's episodes, use the time of day to get the latest episode as fast as possible (and we don't need previous episodes.
		/// For next days, use a 00:00:00 time so as to get all the episode availables.
		var dateString = ""
		if date.isSameDay(as: Date()) {
			let secondsFromGMT = TimeZone.current.secondsFromGMT(for: date)
			let timeZoneOffsetDate = date.addingTimeInterval(-TimeInterval(secondsFromGMT))
			let formatter = DateFormatter()
			// Without this locale phones with 12hr format setting would produce an AM/PM at the end of the string.
			formatter.locale = Locale(identifier: "en_US_POSIX")
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
			dateString = formatter.string(from: timeZoneOffsetDate)
		} else {
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd"
			dateString = formatter.string(from: date) + "T00:00:00"
		}
		var path = "/v1/episodes?starting_at=\(dateString)"
		if let daysAhead = daysAhead {
			path += "&days_ahead=\(daysAhead)"
		}
		let paginator = RestApiPaginator<JSONEpisode, Episode>(baseUrl: baseUrl,
																																 path,
																																 client: network, mapping: { $0.toEpisode() })
		return AnyPaginator(paginator)
	}

	public func registerForEpisodeUpdates() -> AnyPublisher<EpisodeStatusUpdate, Error> {
		webSocket.joinEpisodeUpdates()
	}

	public func leaveEpisodeUpdates() {
		webSocket.leaveEpisodeUpdates()
	}

	public func fetchBroadcastUrl(for episode: Episode) -> AnyPublisher<Episode, Error> {
		get("/v1/episodes/\(episode.id)/watch").map { (response: WatchJSONResponse) in
			let streamType = response.stream_type
			var newEpisode = episode

			// BroadcastUrl
			if streamType == nil || streamType == "live_stream" {
				if episode.vodId == nil && !response.broadcast_url.isEmpty {
					newEpisode.broadcastUrl = response.broadcast_url
				}
			}

			// Elapsed time
			if streamType == nil || streamType == "pre_recorded_live_stream" {
				if let elapsed_time = response.elapsed_time,
					 let time = elapsed_time.split(separator: ".").first,
					 let timeInt = String(time).toSeconds() {
					newEpisode.elapsedTime = TimeInterval(Float(timeInt))
					newEpisode.elapsedTimeDate = Date()
				}
			}

			return newEpisode
		}
		.eraseToAnyPublisher()
	}

	public func registerDevice(token: String) -> AnyPublisher<Void, Error> {
		return post("/device-registration-tokens", params: ["token" : token])
			.map { () -> Void in }
			.eraseToAnyPublisher()
	}

	public func subscribe(to episode: Episode) -> AnyPublisher<Void, Error> {
		let params: [String: CustomStringConvertible] = [
			"topic_type": "episode",
			"topic_id": episode.id
		]
		return post("/push-notifications/subscribe", params: params)
			.map { () -> Void in }
			.eraseToAnyPublisher()
	}

	public func unSubscribe(from episode: Episode) -> AnyPublisher<Void, Error> {
		let params: [String: CustomStringConvertible] = [
			"topic_type": "episode",
			"topic_id": episode.id
		]
		return post("/push-notifications/unsubscribe", params: params)
			.map { () -> Void in }
			.eraseToAnyPublisher()
	}
}

public struct WatchJSONResponse: Decodable, NetworkingJSONDecodable {
	public let stream_type: String?
	public let broadcast_url: String
	public let elapsed_time: String?
}

extension JSONEpisode: NetworkingJSONDecodable {}
extension JSONShow: NetworkingJSONDecodable {}

public extension Date {
	func isSameDay(as date: Date) -> Bool {
		var calender = Calendar.current
		calender.timeZone = TimeZone.current
		let result = calender.compare(self, to: date, toGranularity: .day)
		return result == .orderedSame
	}
}
