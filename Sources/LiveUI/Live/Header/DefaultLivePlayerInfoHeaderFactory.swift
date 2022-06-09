//
//  DefaultLivePlayerInfoHeaderFactory.swift
//  
//
//  Created by Sacha Durand Saint Omer on 09/06/2022.
//

import Foundation
import SwiftUI
import Live

public class DefaultLivePlayerInfoHeaderFactory: LivePlayerInfoHeaderFactory {
	
	public func makeLivePlayerInfoHeaderView(episode: Episode, regularFont: String, close: @escaping () -> Void) -> some View {
		LivePlayerInfoHeader(title: episode.title,
												 isLive: episode.status == .broadcasting,
												 regularFont: "",
												 close: close)
	}
	
	public init() {}
}
