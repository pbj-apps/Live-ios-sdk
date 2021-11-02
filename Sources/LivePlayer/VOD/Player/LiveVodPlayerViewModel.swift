//
//  LiveVodPlayerViewModel.swift
//
//
//  Created by Sacha on 29/10/2021.
//

import SwiftUI
import AVKit

public class LiveVodPlayerViewModel: NSObject, ObservableObject {
	
	@Published var showsControls: Bool = true
	@Published var isPlaying: Bool = false
	@Published var sliderValue: Float = 0
	@Published var player: AVPlayer
	@Published var currentTimeLabel: String = "0:00"
	@Published var endTimeLabel: String = "0:00"
	private var isEditingSlider: Bool = false
	private var timeObserver: Any?
	private var fadeOutTimer: Timer?
	private var playerItemContext = 0
	
	public init(url: URL) {
		self.player	= AVPlayer(url: url)
		super.init()
		self.player.currentItem?.addObserver(self,
																				 forKeyPath: #keyPath(AVPlayerItem.status),
																				 options: [.old, .new],
																				 context: &playerItemContext)
		let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
			if let self = self {
				self.refreshCurrentTimeLabel()
				if !self.isEditingSlider {
					let currentTime = (CMTimeGetSeconds(time) / self.player.currentItem!.duration.seconds)
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
	
	public override func observeValue(forKeyPath keyPath: String?,
																		of object: Any?,
																		change: [NSKeyValueChangeKey : Any]?,
																		context: UnsafeMutableRawPointer?) {
		// Only handle observations for the playerItemContext
		guard context == &playerItemContext else {
			super.observeValue(forKeyPath: keyPath,
												 of: object,
												 change: change,
												 context: context)
			return
		}
		
		if keyPath == #keyPath(AVPlayerItem.status) {
			let status: AVPlayerItem.Status
			if let statusNumber = change?[.newKey] as? NSNumber {
				status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
			} else {
				status = .unknown
			}
			
			switch status {
			case .readyToPlay:
				refreshEndTimeLabel()
			case .failed, .unknown: ()
			}
		}
	}
	
	private func refreshCurrentTimeLabel() {
		let currentTimeSeconds = self.player.currentTime().seconds
		let currentTimeString = self.formattedTime(seconds: currentTimeSeconds)
		if self.endTimeLabel != currentTimeString {
			self.currentTimeLabel = currentTimeString
		}
	}
	
	private func refreshEndTimeLabel() {
		if let durationSeconds = player.currentItem?.duration.seconds {
			let endTimeString = formattedTime(seconds: durationSeconds)
			if endTimeLabel != endTimeString {
				endTimeLabel = endTimeString
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
