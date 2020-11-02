//
//  VodPlaylist.swift
//  
//
//  Created by Sacha on 02/08/2020.
//

import Foundation

public struct VodPlaylist: IsVodItem, Hashable {
	public let id: String
	public let title: String
	public let description: String
	public var isFeatured: Bool
	public let thumbnailImageUrl: URL?
	public let videos: [VodVideo]
	public let videoCount: Int
	public init (id: String, title: String, description: String, isFeatured: Bool, thumbnailImageUrl: URL?, videos: [VodVideo], videoCount: Int) {
		self.id = id
		self.title = title
		self.description = description
		self.isFeatured = isFeatured
		self.thumbnailImageUrl = thumbnailImageUrl
		self.videos = videos
		self.videoCount = videoCount
	}
}
