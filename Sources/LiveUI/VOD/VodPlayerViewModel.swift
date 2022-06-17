//
//  VodPlayerViewModel.swift
//
//
//  Created by Sacha on 29/10/2021.
//

import SwiftUI
import AVKit
import Live

public class VodPlayerViewModel: NSObject, ObservableObject {
	
	@Published var showsControls: Bool = true
	@Published var isPlaying: Bool = false
	@Published var progress: Float = 0
	@Published var player: AVPlayer
	@Published var currentTimeSeconds: Double = 0
	@Published var durationSeconds: Double = 0
	@Published var products = [Product]()
	private var isEditingSlider: Bool = false
	private var timeObserver: Any?
	private var fadeOutTimer: Timer?
	private var playerItemContext = 0
	private var didPlay: (() -> Void)?
	
	public convenience init(video: VodVideo,
													productRepository: ProductRepository = LiveSDKInstance.shared,
													didPlay: (() -> Void)?) {
		self.init(url: video.videoURL ?? URL(string:"http://")!, didPlay: didPlay)
		
		Task { @MainActor in
			products = try await productRepository.fetchProducts(for: video)
		}
	}
	
	public init(url: URL, didPlay: (() -> Void)?) {
		self.player	= AVPlayer(url: url)
		self.didPlay = didPlay
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
                    var currentTime: Float64 = 0
                    if let duration = self.player.currentItem!.duration {
                        currentTime = CMTimeGetSeconds(time) / CMTimeGetSeconds(duration)
                    }
					withAnimation {
						self.progress = Float(currentTime)
					}
				}
			}
		}
	}
	
	public func play() {
		player.play()
		didPlay?()
		didPlay = nil
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
	
	public func endSeek() {
		isEditingSlider = false
		if isPlaying {
			player.play()
			fadeOutControlsLater()
		}
	}
	
	public func seekToSeconds(seconds: Double) {
		isEditingSlider = true
		player.pause()
		player.seek(to: CMTime(seconds: seconds, preferredTimescale: 1))
		progress = Float((seconds / (player.currentItem?.duration.seconds ?? 1)))
	}
	
	public func sliderChanged(value :Float) {
		player.pause()
		let sec = Double(value * Float((player.currentItem?.duration.seconds)!))
		player.seek(to: CMTime(seconds: sec, preferredTimescale: 1))
		progress = value
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
		let currentTime = player.currentTime().seconds
		if currentTimeSeconds != currentTime {
			currentTimeSeconds = currentTime
		}
	}
	
	private func refreshEndTimeLabel() {
		if let duration = player.currentItem?.duration.seconds {
			if durationSeconds != duration {
				durationSeconds = duration
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
		player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
	}
}
