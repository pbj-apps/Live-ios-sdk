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
	public let chatMode: ChatMode
	public let instructor: User
	public let previewImageUrl: String?
	public let previewVideoUrl: String?
	public let startDate: Date
	public let endDate: Date
	public var waitingRomDescription: String
	
	public init(
		id: String,
		title: String,
		description: String,
		duration: Int,
		status: LiveStreamStatus,
		showId: String,
		broadcastUrl: String?,
		chatMode: ChatMode,
		instructor: User,
		previewImageUrl: String?,
		previewVideoUrl: String?,
		startDate: Date,
		endDate: Date,
		waitingRomDescription: String) {
		self.id = id
		self.title = title
		self.description = description
		self.duration = duration
		self.status = status
		self.showId = showId
		self.broadcastUrl = broadcastUrl
		self.chatMode = chatMode
		self.instructor = instructor
		self.previewImageUrl = previewImageUrl
		self.previewVideoUrl = previewVideoUrl
		self.startDate = startDate
		self.endDate = endDate
		self.waitingRomDescription = waitingRomDescription
	}
}

public enum LiveStreamStatus: Hashable {
	case idle
	case waitingRoom
	case broadcasting
	case finished
}

public enum ChatMode: String {
	case disabled
	case enabled
	case qna
}

public struct LiveStreamStatusUpdate {
	public let id: String
	public let waitingRoomDescription: String
	public let status: LiveStreamStatus
}
