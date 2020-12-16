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
	public let instructor: User?

	public init(
		id: String,
		title: String,
		description: String,
		isFeatured: Bool,
		thumbnailImageUrl: URL?,
		videoURL: URL?,
		duration: Int?,
		instructor: User?) {
		self.id = id
		self.title = title
		self.description = description
		self.isFeatured = isFeatured
		self.thumbnailImageUrl = thumbnailImageUrl
		self.videoURL = videoURL
		self.duration = duration
		self.instructor = instructor
	}
}
