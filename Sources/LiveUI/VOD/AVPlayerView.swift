//
//  AVPlayerView.swift
//  
//
//  Created by Sacha DSO on 22/11/2021.
//

import Foundation
import UIKit
import AVKit

final class AVPlayerView: UIView {

	override static var layerClass: AnyClass { AVPlayerLayer.self }
	var playerLayer: AVPlayerLayer? { layer as? AVPlayerLayer }
	var player: AVPlayer? {
		get { playerLayer?.player }
		set { playerLayer?.player = newValue }
	}
}
