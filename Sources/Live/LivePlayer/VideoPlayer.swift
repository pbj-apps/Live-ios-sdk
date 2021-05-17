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

public struct VideoPlayer: UIViewRepresentable {

	let url: String
	let looping: Bool
	let isPlaying: Bool
	let isLive: Bool
	let isMuted: Bool

	public init(url: String, looping: Bool, isPlaying: Bool, isLive: Bool = true, isMuted: Bool = false) {
		self.url = url
		self.looping = looping
		self.isPlaying = isPlaying
		self.isLive = isLive
		self.isMuted = isMuted
	}

	public func makeUIView(context: Context) -> UIView {
		let playerView = VideoAVPlayerView()
		playerView.playerLayer?.videoGravity = .resizeAspectFill
		context.coordinator.loadPlayer(url: url, in: playerView, isLooping: looping, isLive: isLive)
		return playerView
	}

	public func updateUIView(_ uiView: UIView, context: Context) {
		if isPlaying {
			if isLive {
				// Keep close to direct as much as possible.
				context.coordinator.player?.seek(to: CMTime.positiveInfinity)
			}
			context.coordinator.player?.play()
		} else {
			context.coordinator.player?.pause()
		}
		context.coordinator.player?.isMuted = isMuted
	}

	public func makeCoordinator() -> VideoPlayer.Coordinator {
		return Coordinator()
	}

	public class Coordinator: NSObject {

		var url: String = ""
		var looper: AVPlayerLooper?
		var player: AVPlayer?
		var playerView: VideoAVPlayerView?
		var isLooping: Bool = false
		var isLive: Bool = false
		var playerItemContext = 0

		func loadPlayer(url: String, in playerView: VideoAVPlayerView, isLooping: Bool, isLive: Bool) {
			self.url = url
			self.playerView = playerView
			self.isLooping = isLooping
			self.isLive = isLive
			self.reloadPlayer()
		}

		func reloadPlayer() {
			if let assetURL = URL(string: url) {
				let asset = AVAsset(url: assetURL)
				let playerItem = AVPlayerItem(asset: asset)

				if isLive {
					playerItem.automaticallyPreservesTimeOffsetFromLive = true
					playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true

					// Register as an observer of the player item's status property
					playerItem.addObserver(self,
																		 forKeyPath: #keyPath(AVPlayerItem.status),
																		 options: [.old, .new],
																		 context: &playerItemContext)
				}

				if isLooping {
					let queuePlayer = AVQueuePlayer(playerItem: playerItem)
					looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
					player = queuePlayer
				} else {
					player = AVPlayer(playerItem: playerItem)
					player?.automaticallyWaitsToMinimizeStalling = true
				}
				playerView?.player = player
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
					player?.play()
				case .failed:
					// Typical case is that Livestream just started and not ready to play yet.
					// Retry 5s later.
					Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
						self.reloadPlayer()
					}
				case .unknown:()
				}
			}
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
