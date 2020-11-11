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

	public init(url: String, looping: Bool, isPlaying: Bool) {
		self.url = url
		self.looping = looping
		self.isPlaying = isPlaying
	}

	public func makeUIView(context: Context) -> UIView {
		let playerView = VideoAVPlayerView()
		playerView.playerLayer?.videoGravity = .resizeAspectFill
		if let assetURL = URL(string: url) {
			let asset = AVAsset(url: assetURL)
			let playerItem = AVPlayerItem(asset: asset)
			let player = AVQueuePlayer(playerItem: playerItem)
			if looping {
				context.coordinator.looper = AVPlayerLooper(player: player, templateItem: playerItem)
			}
			playerView.player = player
			context.coordinator.player = player
		}
		return playerView
	}

	public func updateUIView(_ uiView: UIView, context: Context) {
		if isPlaying {
			context.coordinator.player?.play()
		} else {
			context.coordinator.player?.pause()
		}
	}

	public func makeCoordinator() -> VideoPlayer.Coordinator {
		return Coordinator()
	}

	public class Coordinator {
		var looper: AVPlayerLooper?
		var player: AVPlayer?
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
