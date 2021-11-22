//
//  VODVideoPlayer.swift
//  
//
//  Created by Sacha DSO on 24/05/2021.
//

import SwiftUI
import UIKit
import AVKit


public struct SwiftUIAVPlayer: UIViewRepresentable {

	let player: AVPlayer

	public init(player: AVPlayer) {
		self.player = player
	}
	
	public func makeUIView(context: Context) -> UIView {
		let playerView = AVPlayerView()
		context.coordinator.load(player: player, in: playerView)
		return playerView
	}

	public func updateUIView(_ uiView: UIView, context: Context) {

	}

	public func makeCoordinator() -> Coordinator {
		return Coordinator()
	}

	public class Coordinator: NSObject, AVPictureInPictureControllerDelegate {

		var playerView: AVPlayerView?
		var pictureInPictureController: AVPictureInPictureController?

		func load(player: AVPlayer, in playerView: AVPlayerView) {
			self.playerView = playerView
			self.playerView?.player = player

			// Enable Picture in picture (PiP) if available
			if AVPictureInPictureController.isPictureInPictureSupported() {
				pictureInPictureController = AVPictureInPictureController(playerLayer: playerView.playerLayer!)
			}
		}
	}
}

