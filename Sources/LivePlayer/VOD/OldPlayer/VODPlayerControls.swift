//
//  VODPlayerControls.swift
//  
//
//  Created by Sacha DSO on 24/05/2021.
//

import SwiftUI
import AVKit

public struct VODPlayerControls: View {

	@Binding var player: AVPlayer
	@Binding var isPlaying: Bool
	@Binding var sliderValue: Float

	public init(player: Binding<AVPlayer>, isPlaying: Binding<Bool>, sliderValue: Binding<Float>) {
		self._player =  player
		self._isPlaying = isPlaying
		self._sliderValue = sliderValue
	}

	public var body: some View {
		HStack(spacing: 0) {
			playButton
			VODCustomProgressBar(value: $sliderValue, player: $player, isPlaying: $isPlaying)
		}
	}

	var playButton: some View {
		Button(action: {
			if isPlaying {
				player.pause()
			} else {
				player.play()
			}
			isPlaying.toggle()
		}) {
			Image(systemName: isPlaying ? "pause.fill" : "play.fill")
				.font(.title)
				.foregroundColor(.white)
				.padding()
				.contentShape(Rectangle())
		}
	}
}


