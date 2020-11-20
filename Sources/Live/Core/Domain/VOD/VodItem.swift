//
//  VodItem.swift
//  
//
//  Created by Sacha on 02/08/2020.
//

import Foundation

public struct VodItem: Identifiable, Hashable {

	public init(type: VodItemType) {
		self.type = type
	}
	public let type: VodItemType
	public var id: String { item.id }
	public var title: String { item.title }
	public var description: String { item.description }
	public var isFeatured: Bool {
		get { item.isFeatured }
		set {
			switch type {
			case .video(var video):
				video.isFeatured = newValue
			case .playlist(var playlist):
				playlist.isFeatured = newValue
			}
		}
	}
	public var thumbnailImageUrl: URL? { item.thumbnailImageUrl }
	public var isVideo: Bool {
		switch type {
		case .video:
			return true
		case .playlist:
			return false
		}
	}

	private var item: IsVodItem {
		switch type {
		case .video(let video):
			return video
		case .playlist(let playlist):
			return playlist
		}
	}
}

protocol IsVodItem {
	var id: String { get }
	var title: String { get }
	var description: String { get }
	var isFeatured: Bool { get set }
	var thumbnailImageUrl: URL? { get }
}
