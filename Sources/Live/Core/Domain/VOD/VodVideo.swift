//
//  VodVideo.swift
//  
//
//  Created by Sacha on 02/08/2020.
//

import Foundation

public struct VodVideo: IsVodItem, Hashable, Identifiable {

	public let id: String
	public let title: String
	public let description: String
	public var isFeatured: Bool
	public let thumbnailImageUrl: URL?
	public let videoURL: URL?
	public let duration: Int?
	public let instructors: [User]
	public let categories: [VodCategory]
	public var instructor: User? {
		return instructors.first
	}

	public init(
		id: String,
		title: String,
		description: String,
		isFeatured: Bool,
		thumbnailImageUrl: URL?,
		videoURL: URL?,
		duration: Int?,
		instructors: [User] = [User](),
		categories: [VodCategory] = [VodCategory]()) {
		self.id = id
		self.title = title
		self.description = description
		self.isFeatured = isFeatured
		self.thumbnailImageUrl = thumbnailImageUrl
		self.videoURL = videoURL
		self.duration = duration
		self.instructors = instructors
		self.categories = categories
	}
}
