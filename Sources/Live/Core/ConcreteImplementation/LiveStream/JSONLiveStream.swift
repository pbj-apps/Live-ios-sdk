//
//  JSONLiveStream.swift
//  
//
//  Created by Sacha on 11/08/2020.
//

import Foundation

struct JSONLiveStream: Decodable {
	let id: String
	let title: String
	let description: String
	let duration: Int
	let status: String
	let showId: String
	let broadcastUrlString: String?
	let chatMode: ChatMode
	let instructor: JSONUser?
	let previewImageUrl: String?
	let previewVideoUrl: String?
	let startDate: String
	let endDate: String
	let waitingRoomDescription: String

	enum CodingKeys: String, CodingKey {
		case id
		case title
		case description
		case duration
		case streamer
		case chat_mode
		case status
		case starting_at
		case ends_at
		case show
		case streaming_info
	}

	enum ShowKeys: String, CodingKey {
		case id
		case preview_asset
		case waiting_room_description
	}

	enum StreamingInfoKeys: String, CodingKey {
		case broadcast_url
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(String.self, forKey: .id)
		title = try values.decode(String.self, forKey: .title)
		description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
		duration = try values.decode(Int.self, forKey: .duration)
		instructor = try? values.decode(JSONUser.self, forKey: .streamer)
		status = try values.decode(String.self, forKey: .status)
		chatMode = ChatMode(rawValue: try values.decode(String.self, forKey: .chat_mode)) ?? .disabled
		startDate = try values.decode(String.self, forKey: .starting_at)
		endDate = try values.decode(String.self, forKey: .ends_at)
		let showKeys = try values.nestedContainer(keyedBy: ShowKeys.self, forKey: .show)
		showId = try showKeys.decode(String.self, forKey: .id)

		let previewAsset = try? showKeys.decode(JSONPreviewAsset.self, forKey: .preview_asset)
		previewImageUrl = previewAsset?.image.medium
		previewVideoUrl = previewAsset?.asset_type == "video" ? previewAsset?.asset_url : nil
		let streamingInfoKeys = try? values.nestedContainer(keyedBy: StreamingInfoKeys.self, forKey: .streaming_info)
		broadcastUrlString = try? streamingInfoKeys?.decode(String.self, forKey: .broadcast_url)
		waitingRoomDescription = try showKeys.decode(String.self, forKey: .waiting_room_description)
	}
}

extension JSONLiveStream {
	func toLiveStream() -> LiveStream {
		return LiveStream(id: id,
											title: title,
											description: description,
											duration: duration,
											status: LiveStreamStatus.fromString(status),
											showId: showId,
											broadcastUrl: broadcastUrlString,
											chatMode: chatMode,
											instructor: instructor?.toUser() ?? User(firstname: "no streamer", lastname: "no streamer", email: "no streamer", username: "username", hasAnsweredSurvey: false, avatarUrl: nil),
											previewImageUrl: previewImageUrl,
											previewVideoUrl: previewVideoUrl,
											startDate: startDate.toRestApiDate() ?? Date(),
											endDate: endDate.toRestApiDate() ?? Date(),
											waitingRomDescription: waitingRoomDescription)
	}
}

extension String {
	func toRestApiDate() -> Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ssZ"
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter.date(from: self)
	}
}

extension LiveStreamStatus {
	static func fromString(_ statusString: String) -> LiveStreamStatus {
		switch statusString {
		case "idle":
			return .idle
		case "waiting_room":
			return .waitingRoom
		case "broadcasting":
			return .broadcasting
		case "finished":
			return .finished
		default:
			return .idle
		}
	}
}
