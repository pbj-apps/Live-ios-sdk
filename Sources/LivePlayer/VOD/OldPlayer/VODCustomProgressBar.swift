//
//  VODCustomProgressBar.swift
//  
//
//  Created by Sacha on 29/10/2021.
//

import SwiftUI
import AVKit

struct VODCustomProgressBar: UIViewRepresentable {

	@Binding var value: Float
	@Binding var player: AVPlayer
	@Binding var isPlaying: Bool

	public init(value: Binding<Float>, player: Binding<AVPlayer>, isPlaying: Binding<Bool>) {
		self._value = value
		self._player = player
		self._isPlaying = isPlaying
	}

	func makeUIView(context: UIViewRepresentableContext<VODCustomProgressBar>) -> UISlider {
		let slider = UISlider()
		slider.minimumTrackTintColor = .white
		slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.2)
		slider.thumbTintColor = .clear
		slider.addTarget(context.coordinator, action: #selector(context.coordinator.sliderChanged(slider:)), for: .valueChanged)
		return slider
	}

	func updateUIView(_ uiView: UISlider, context: UIViewRepresentableContext<VODCustomProgressBar>) {
		uiView.value = value
		context.coordinator.player = player
		context.coordinator.isPlaying = isPlaying
	}

	func makeCoordinator() -> Coordinator {
		return Coordinator()
	}

	class Coordinator {

		var isPlaying: Bool = false
		var player: AVPlayer?

		@objc
		func sliderChanged(slider : UISlider) {
			if let player = player {
				if slider.isTracking {
					player.pause()
					let sec = Double(slider.value * Float((player.currentItem?.duration.seconds)!))
					player.seek(to: CMTime(seconds: sec, preferredTimescale: 1))
				}
				else {
					let sec = Double(slider.value * Float((player.currentItem?.duration.seconds)!))
					player.seek(to: CMTime(seconds: sec, preferredTimescale: 1))
					if isPlaying {
						player.play()
					}
				}
			}
		}
	}
}
