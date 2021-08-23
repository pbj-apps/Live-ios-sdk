//
//  LiveStream.swift
//  
//
//  Created by Sacha on 26/07/2020.
//

import Foundation

public struct LiveStream: Identifiable, Hashable {
	public let internalId = UUID()
	public let id: String
	public let title: String
	public let description: String
	public let duration: Int
	public var status: LiveStreamStatus
	public let showId: String
	public var broadcastUrl: String?
	public let instructor: User
	public let previewImageUrl: String?
	public let previewImageUrlFullSize: String?
	public let previewVideoUrl: String?
	public let startDate: Date
	public let endDate: Date
	public var waitingRomDescription: String
	public var elapsedTime: TimeInterval?
	public var elapsedTimeDate: Date?
	public var vodId: String?
	public var isPushNotificationReminderSet: Bool

	public func timeElapsed() -> TimeInterval? {
		guard let elapsedTime = elapsedTime else {
			return nil
		}
		if let elapsedTimeDate = elapsedTimeDate {
			return Date().timeIntervalSince(elapsedTimeDate) + elapsedTime
		}
		return elapsedTime
	}

	public init(
		id: String,
		title: String,
		description: String,
		duration: Int,
		status: LiveStreamStatus,
		showId: String,
		broadcastUrl: String?,
		instructor: User,
		previewImageUrl: String?,
		previewImageUrlFullSize: String?,
		previewVideoUrl: String?,
		startDate: Date,
		endDate: Date,
		waitingRomDescription: String,
		isPushNotificationReminderSet: Bool) {
		self.id = id
		self.title = title
		self.description = description
		self.duration = duration
		self.status = status
		self.showId = showId
		self.broadcastUrl = broadcastUrl
		self.instructor = instructor
		self.previewImageUrl = previewImageUrl
		self.previewImageUrlFullSize = previewImageUrlFullSize
		self.previewVideoUrl = previewVideoUrl
		self.startDate = startDate
		self.endDate = endDate
		self.waitingRomDescription = waitingRomDescription
		self.isPushNotificationReminderSet = isPushNotificationReminderSet
	}
}

public enum LiveStreamStatus: Hashable {
	case idle
	case waitingRoom
	case broadcasting
	case finished
}

public struct LiveStreamStatusUpdate {
	public let id: String
	public let waitingRoomDescription: String
	public let status: LiveStreamStatus
}
