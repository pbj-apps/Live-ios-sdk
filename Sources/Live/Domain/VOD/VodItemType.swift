//
//  VodItemType.swift
//  
//
//  Created by Sacha on 24/07/2020.
//

import Foundation

public enum VodItemType: Hashable {
	case video(VodVideo)
	case playlist(VodPlaylist)
}
