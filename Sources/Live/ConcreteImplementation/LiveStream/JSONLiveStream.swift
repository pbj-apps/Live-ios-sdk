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
	var broadcastUrlString: String?
	let instructor: JSONUser?
	let previewImageUrl: String?
	let previewImageUrlFullSize: String?
	let previewVideoUrl: String?
	let startDate: String
	let endDate: String?
	let waitingRoomDescription: String
	let isPushNotificationReminderSet: Bool

	let vodId: String?

	enum CodingKeys: String, CodingKey {
		case id
		case title
		case description
		case waiting_room_description
		case duration
		case status
		case instructors
		case preview_asset
		case starting_at
		case ends_at
		case streaming_info
		case pre_recorded_video
		case is_push_notification_enabled
	}

	enum StreamingInfoKeys: String, CodingKey {
		case broadcast_url
	}

	enum PreRecordedVideoKeys: String, CodingKey {
		case id
		case asset
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(String.self, forKey: .id)
		title = try values.decode(String.self, forKey: .title)
		description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
		duration = try values.decode(Int.self, forKey: .duration)
		let instructors = try? values.decode([JSONUser].self, forKey: .instructors)
				instructor = instructors?.first
		status = try values.decode(String.self, forKey: .status)
		startDate = try values.decode(String.self, forKey: .starting_at)
		endDate = try? values.decode(String.self, forKey: .ends_at)
		let previewAsset = try? values.decode(JSONPreviewAsset.self, forKey: .preview_asset)
		previewImageUrl = previewAsset?.image.medium
		previewImageUrlFullSize = previewAsset?.image.full_size
		previewVideoUrl = previewAsset?.asset_type == "video" ? previewAsset?.asset_url : nil
		waitingRoomDescription = (try? values.decode(String.self, forKey: .waiting_room_description)) ?? ""
		let preRecordedVideoNode = try? values.nestedContainer(keyedBy: PreRecordedVideoKeys.self, forKey: .pre_recorded_video)
		vodId = try? preRecordedVideoNode?.decode(String.self, forKey: .id)
		if let asset = try? preRecordedVideoNode?.decode(JSONPreviewAsset.self, forKey: .asset) {
			broadcastUrlString = asset.asset_url
		}
		isPushNotificationReminderSet = try values.decodeIfPresent(Bool.self, forKey: .is_push_notification_enabled) ?? false
	}
}

extension JSONLiveStream {
	func toLiveStream() -> LiveStream {
		var liveStream =  LiveStream(id: id,
											title: title,
											description: description,
											duration: duration,
											status: LiveStreamStatus.fromString(status),
											broadcastUrl: broadcastUrlString,
											instructor: instructor?.toUser() ?? User(id: "unknown", firstname: "no streamer", lastname: "no streamer", email: "no streamer", username: "username", hasAnsweredSurvey: false, avatarUrl: nil),
											previewImageUrl: previewImageUrl,
											previewImageUrlFullSize: previewImageUrlFullSize,
											previewVideoUrl: previewVideoUrl,
											startDate: startDate.toRestApiDate() ?? Date(),
											endDate: endDate?.toRestApiDate() ?? Date(),
											waitingRomDescription: waitingRoomDescription,
											isPushNotificationReminderSet: isPushNotificationReminderSet)
		liveStream.vodId = vodId
		return liveStream
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
