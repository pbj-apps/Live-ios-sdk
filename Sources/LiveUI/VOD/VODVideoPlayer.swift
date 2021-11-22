//
//  VODVideoPlayer.swift
//  
//
//  Created by Sacha DSO on 24/05/2021.
//

import SwiftUI
import AVFoundation
import UIKit
import Combine
import AVKit


public struct VODVideoPlayer: UIViewRepresentable {

	let player: AVPlayer

	public init(player: AVPlayer) {
		self.player = player
	}
	
	public func makeUIView(context: Context) -> UIView {
		let playerView = VODVideoAVPlayerView()
		context.coordinator.load(player: player, in: playerView)
		return playerView
	}

	public func updateUIView(_ uiView: UIView, context: Context) {

	}

	public func makeCoordinator() -> Coordinator {
		return Coordinator()
	}

	public class Coordinator: NSObject, AVPictureInPictureControllerDelegate {

		var playerView: VODVideoAVPlayerView?
		var pictureInPictureController: AVPictureInPictureController?

		func load(player: AVPlayer, in playerView: VODVideoAVPlayerView) {
			self.playerView = playerView
			self.playerView?.player = player

			// Enable Picture in picture (PiP) if available
			if AVPictureInPictureController.isPictureInPictureSupported() {
				pictureInPictureController = AVPictureInPictureController(playerLayer: playerView.playerLayer!)
			}
		}
	}
}

final class VODVideoAVPlayerView: UIView {

	override static var layerClass: AnyClass { AVPlayerLayer.self }
	var playerLayer: AVPlayerLayer? { layer as? AVPlayerLayer }
	var player: AVPlayer? {
		get { playerLayer?.player }
		set { playerLayer?.player = newValue }
	}
}
