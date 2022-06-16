//
//  VodPlayerOverlayFactory.swift
//  
//
//  Created by Sacha Durand Saint Omer on 16/06/2022.
//

import Foundation
import SwiftUI
import Live

public protocol VodPlayerOverlayFactory {
	associatedtype V: View
	func makeVodPlayerOverlay(
		products: [Product],
		isPlaying: Bool,
		toggleOverlay: @escaping () -> Void,
		play: @escaping () -> Void,
		pause: @escaping () -> Void,
		seekToSeconds: @escaping (Double) -> Void,
		endSeek: @escaping () -> Void,
		stop: @escaping () -> Void,
		durationSeconds: Double,
		currentTimeSeconds: Double,
		progress: Float,
		close: @escaping () -> Void,
		safeAreaInsets: EdgeInsets) -> V
}
