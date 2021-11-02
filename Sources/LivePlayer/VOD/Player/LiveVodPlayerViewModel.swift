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
	@Published var currentTimeLabel: String = "0:00"
	@Published var endTimeLabel: String = "0:00"
	private var isEditingSlider: Bool = false
	private var timeObserver: Any?
	private var fadeOutTimer: Timer?
	
	public init(url: URL) {
		self.player	= AVPlayer(url: url)
		
		let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
			if let self = self {
				
				// Current time
				let currentTimeSeconds = self.player.currentTime().seconds
				let currentTimeString = self.formattedTime(seconds: currentTimeSeconds)
				if self.endTimeLabel != currentTimeString {
					self.currentTimeLabel = currentTimeString
				}
				
				if !self.isEditingSlider {
					
					// End time
					if let durationSeconds = self.player.currentItem?.duration.seconds {
						let endTimeString = self.formattedTime(seconds: durationSeconds)
						if self.endTimeLabel != endTimeString {
							self.endTimeLabel = endTimeString
						}
					}
					
					// Slider value
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
	
	public func setSliderEditing(isEditing: Bool) {
		isEditingSlider = isEditing
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
	
	func formattedTime(seconds: Double) -> String {
		let timeInterval: TimeInterval = TimeInterval(seconds)
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [.hour, .minute, .second]
		formatter.zeroFormattingBehavior = [.pad]
		let formattedString = formatter.string(from: timeInterval) ?? "0:00"
		if formattedString.starts(with: "00:") {
			return String(formattedString.dropFirst(3))
		}
		return formattedString
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


