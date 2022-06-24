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
    public let images: Images?
	public let videoURL: URL?
	public let duration: Int?
	public let instructors: [User]
	public let categories: [VodCategory]
	public let playlists: [VodPlaylist]
	public var instructor: User? {
		return instructors.first
	}

	public init(
		id: String,
		title: String,
		description: String,
		isFeatured: Bool,
		thumbnailImageUrl: URL?,
        images: Images?,
		videoURL: URL?,
		duration: Int?,
		instructors: [User] = [User](),
		categories: [VodCategory] = [VodCategory](),
		playlists: [VodPlaylist] = [VodPlaylist]()) {
		self.id = id
		self.title = title
		self.description = description
		self.isFeatured = isFeatured
		self.thumbnailImageUrl = thumbnailImageUrl
		self.videoURL = videoURL
        self.images = images
		self.duration = duration
		self.instructors = instructors
		self.categories = categories
		self.playlists = playlists
	}
	
	public init(id: String) {
		self.id = id
		self.title = ""
		self.description = ""
		self.isFeatured = false
		self.thumbnailImageUrl = nil
        self.images = nil
		self.videoURL = nil
		self.duration = nil
		self.instructors = []
		self.categories = []
		self.playlists = []
	}
}
