//
//  LiveVodPlayerViewModel.swift
//
//
//  Created by Sacha on 29/10/2021.
//

import SwiftUI
import AVKit

public class LiveVodPlayerViewModel: ObservableObject {

	@Published var showsControls: Bool = true
	@Published var isPlaying: Bool = false
	@Published var sliderValue: Float = 0
	@Published var player: AVPlayer
	var isEditingSlider: Bool = false
	private var timeObserver: Any?
	private var fadeOutTimer: Timer?

	public init(url: URL) {
		self.player	= AVPlayer(url: url)

		let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
			if let self = self {
				if !self.isEditingSlider {
					let currentTime = (CMTimeGetSeconds(time) / self.player.currentItem!.duration.seconds)//.rounded(toPlaces: 3)
					withAnimation {
						self.sliderValue = Float(currentTime)
					}
				}
			}
		}
	}

	public func play() {
		player.play()
		isPlaying = true
		fadeOutControlsLater()
	}

	public func pause() {
		player.pause()
		isPlaying = false
		showsControls = true
	}

	public func stop() {
		player.pause()
	}

	public func tapped() {
		showsControls = !showsControls
		if isPlaying {
			fadeOutControlsLater()
		}
	}

	public func endEditingSlider() {
		if isPlaying {
			player.play()
			fadeOutControlsLater()
		}
	}

	public func sliderChanged(value : Float) {
		player.pause()
		let sec = Double(value * Float((player.currentItem?.duration.seconds)!))
		player.seek(to: CMTime(seconds: sec, preferredTimescale: 1))
		sliderValue = value
	}

	private func fadeOutControlsLater() {
		fadeOutTimer?.invalidate()
		fadeOutTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
			if let self = self {
				if self.isPlaying && !self.isEditingSlider {
					withAnimation(Animation.easeInOut(duration: 0.8)) {
						self.showsControls = false
					}
				}
			}
		}
	}

	deinit {
		if let timeObserver = timeObserver {
			player.removeTimeObserver(timeObserver)
		}
		timeObserver = nil
		fadeOutTimer?.invalidate()
		fadeOutTimer = nil
	}
}


