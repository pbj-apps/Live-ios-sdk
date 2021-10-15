//
//  VideoPlayer.swift
//  
//
//  Created by Sacha on 09/09/2020.
//

import SwiftUI
import AVFoundation
import UIKit
import Combine
import AVKit
import Live

public struct VideoPlayer: UIViewRepresentable {

	let url: String
	let looping: Bool
	let isPlaying: Bool
	let isLive: Bool
	let isMuted: Bool
	let allowsPictureInPicture: Bool
	let liveStream: LiveStream
	let aspectRatioFit: Bool
	let elapsedTime: TimeInterval?

	public init(
		liveStream: LiveStream,
		url: String,
		looping: Bool,
		isPlaying: Bool,
		isLive: Bool,
		isMuted: Bool,
		allowsPictureInPicture: Bool,
		aspectRatioFit: Bool,
		elapsedTime: TimeInterval?) {
		self.liveStream = liveStream
		self.url = url
		self.looping = looping
		self.isPlaying = isPlaying
		self.isLive = isLive
		self.isMuted = isMuted
		self.allowsPictureInPicture = allowsPictureInPicture
		self.aspectRatioFit = aspectRatioFit
		self.elapsedTime = elapsedTime
	}

	public func makeUIView(context: Context) -> UIView {
		let playerView = VideoAVPlayerView()
		playerView.playerLayer?.videoGravity = aspectRatioFit ? .resizeAspect : .resizeAspectFill
		context.coordinator.loadPlayer(url: url, in: playerView, isLooping: looping, isLive: isLive, allowsPictureInPicture: allowsPictureInPicture)
		return playerView
	}

	public func updateUIView(_ uiView: UIView, context: Context) {
		if isPlaying {
			if isLive {
				// Vod Live
				if liveStream.vodId != nil {
					// Seek vod to correct timing whenever we are too far off. (1 sec)
					if let elapsedTime = elapsedTime, let currentPlayerTime = context.coordinator.player?.currentTime().seconds {
						let timeDifference = abs(currentPlayerTime - elapsedTime)
						if timeDifference > 1 {
							context.coordinator.player?.seek(to: CMTime(seconds: elapsedTime, preferredTimescale: 1))
						}
					}
				} else { // Live
					if !context.coordinator.hasAlreadySeeked {
						// Keep close to direct as much as possible.
						context.coordinator.player?.seek(to: CMTime.positiveInfinity)
						context.coordinator.hasAlreadySeeked = true
					}
				}
			}
			context.coordinator.player?.play()
		} else {
			context.coordinator.player?.pause()
			context.coordinator.hasAlreadySeeked = false
		}
		context.coordinator.player?.isMuted = isMuted
		context.coordinator.isPlaying = isPlaying
		context.coordinator.liveStream = liveStream
	}

	public func makeCoordinator() -> VideoPlayer.Coordinator {
		return Coordinator()
	}

	public class Coordinator: NSObject, AVPictureInPictureControllerDelegate {

		var url: String = ""
		var looper: AVPlayerLooper?
		var player: AVPlayer?
		var playerView: VideoAVPlayerView?
		var isLooping: Bool = false
		var isLive: Bool = false
		var playerItemContext = 0
		var pictureInPictureController: AVPictureInPictureController?
		var playerItem: AVPlayerItem?
		var isPlaying: Bool = false
		var liveStream: LiveStream?
		var hasAlreadySeeked = false

		func loadPlayer(url: String, in playerView: VideoAVPlayerView, isLooping: Bool, isLive: Bool, allowsPictureInPicture: Bool) {
			self.url = url
			self.playerView = playerView
			self.isLooping = isLooping
			self.isLive = isLive
			self.reloadPlayer()

			// Enable Picture in picture (PiP) if available
			if allowsPictureInPicture && AVPictureInPictureController.isPictureInPictureSupported() {
				pictureInPictureController = AVPictureInPictureController(playerLayer: playerView.playerLayer!)
			}
		}

		func reloadPlayer() {
			if let assetURL = URL(string: url) {
				let asset = AVAsset(url: assetURL)
				playerItem = AVPlayerItem(asset: asset)

				if isLive {
					playerItem?.automaticallyPreservesTimeOffsetFromLive = true
					playerItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true

					// Register as an observer of the player item's status property
					playerItem?.addObserver(self,
																		 forKeyPath: #keyPath(AVPlayerItem.status),
																		 options: [.old, .new],
																		 context: &playerItemContext)
				}

				if isLooping {
					let queuePlayer = AVQueuePlayer(playerItem: playerItem)
					looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem!)
					player = queuePlayer
				} else {
					player = AVPlayer(playerItem: playerItem)
					player?.automaticallyWaitsToMinimizeStalling = true
				}
				playerView?.player = player
				
				NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)),
																							 name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
																							 object: player!.currentItem)
			}
		}

		public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

			//Only handle observations for the playerItemContext
			guard context == &playerItemContext else {
				super.observeValue(forKeyPath: keyPath,
													 of: object,
													 change: change,
													 context: context)
				return
			}

			if keyPath == #keyPath(AVPlayerItem.status) {
				let status: AVPlayerItem.Status

				// Get the status change from the change dictionary
				if let statusNumber = change?[.newKey] as? NSNumber {
					status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
				} else {
					status = .unknown
				}

				// Switch over the status
				switch status {
				case .readyToPlay:
					if isPlaying {
						player?.play()
					}
				case .failed:
					// Typical case is that Livestream just started and not ready to play yet.
					// Retry 5s later.
					Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
						self.reloadPlayer()
					}
				case .unknown:()
				@unknown default:()
				}
			}
		}

		@objc
		func playerDidFinishPlaying(note: NSNotification) {
			liveStream?.status = .finished
			NotificationCenter.default.post(name: NSNotification.Name("PBJLiveStreamDidEndStreaming"), object: liveStream)
		}

		deinit {
			player?.pause()
			if isLive {
				playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
			}
			NotificationCenter.default.removeObserver(self)
		}
	}
}

final class VideoAVPlayerView: UIView {

	override static var layerClass: AnyClass { AVPlayerLayer.self }
	var playerLayer: AVPlayerLayer? { layer as? AVPlayerLayer }
	var player: AVPlayer? {
		get { playerLayer?.player }
		set { playerLayer?.player = newValue }
	}
}
