//
//  DefaultVodPlayerOverlayFactory.swift
//  
//
//  Created by Sacha Durand Saint Omer on 16/06/2022.
//

import Foundation
import SwiftUI
import Live

public class DefaultVodPlayerOverlayFactory: VodPlayerOverlayFactory {
	
	public func makeVodPlayerOverlay(
		products: [Product],
		isPlaying: Bool,
		toggleOverlay: @escaping () -> Void,
		play: @escaping () -> Void,
		pause: @escaping () -> Void,
		seekToSeconds:  @escaping (Double) -> Void,
		endSeek: @escaping () -> Void,
		stop: @escaping () -> Void,
		durationSeconds: Double,
		currentTimeSeconds: Double,
		progress: Float,
		close: @escaping () -> Void,
		safeAreaInsets: EdgeInsets) -> some View {
			VodPlayerOverlay(
				isPlaying: isPlaying,
				tapped: toggleOverlay,
				play: play,
				pause: pause,
				stop: stop,
				currentTimeSeconds: currentTimeSeconds,
				durationSeconds: durationSeconds,
				sliderValue: progress,
				seekToProgress: { progress in
					seekToSeconds(durationSeconds * Double(progress))
				},
				endSeek: endSeek,
				close: close,
				safeAreaInsets: safeAreaInsets,
				topLeftButton: nil)// topLeftButton)
		}
}
