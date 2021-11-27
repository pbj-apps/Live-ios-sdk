//
//  Episode.swift
//  
//
//  Created by Sacha on 26/07/2020.
//

import Foundation

public struct Episode: Identifiable, Hashable {
	public let internalId = UUID()
	public let id: String
	public let title: String
	public let description: String
	public let duration: Int
	public var status: Status
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
		status: Status,
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
	
	public init(id: String) {
		self.id = id
		self.title = ""
		self.description = ""
		self.duration = 0
		self.status = .idle
		self.broadcastUrl = nil
		self.instructor = User(id: "", firstname: "", lastname: "", email: nil, username: "", hasAnsweredSurvey: nil, avatarUrl: nil)
		self.previewImageUrl = nil
		self.previewImageUrlFullSize = nil
		self.previewVideoUrl = nil
		self.startDate = Date()
		self.endDate = Date()
		self.waitingRomDescription = ""
		self.isPushNotificationReminderSet = false
	}
}

public struct EpisodeStatusUpdate {
	public let id: String
	public let waitingRoomDescription: String
	public let status: Status
}
