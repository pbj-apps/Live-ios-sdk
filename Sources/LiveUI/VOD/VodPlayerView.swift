//
//  VodPlayerView.swift
//  
//
//  Created by Sacha on 29/10/2021.
//

import SwiftUI
import AVFoundation
import Live

public struct VodPlayerView<OverlayFactory: VodPlayerOverlayFactory>: View {
	
	let player: AVPlayer
	let showsControls: Bool
	let isPlaying: Bool
	let tapped: () -> Void
	let play: () -> Void
	let pause: () -> Void
	let seekToSeconds: (Double) -> Void
	let endSeek: () -> Void
	let stop: () -> Void
	let currentTimeSeconds: Double
	let durationSeconds: Double
	let progress: Float
	let close: () -> Void
	let topLeftButton: AnyView?
	let overlayFactory: OverlayFactory
	let products: [Product]
	
	public var body: some View {
		GeometryReader { proxy in
			ZStack {
				Color.black
				SwiftUIAVPlayer(player: player)
					.onTapGesture {
						withAnimation {
							tapped()
						}
					}
				overlayFactory.makeVodPlayerOverlay(
					products: products,
					isPlaying: isPlaying,
					toggleOverlay: tapped,
					play: play,
					pause: pause,
					seekToSeconds: seekToSeconds,
					endSeek: endSeek,
					stop: stop,
					durationSeconds: durationSeconds,
					currentTimeSeconds: currentTimeSeconds,
					progress: progress,
					close: close,
					safeAreaInsets: proxy.safeAreaInsets)
				.opacity(showsControls ? 1 : 0)
			}
			.edgesIgnoringSafeArea(.all)
		}
	}
}

struct LiveVodPlayerView_Previews: PreviewProvider {
	static var previews: some View {
		VodPlayerView(player: AVPlayer(),
									showsControls: true,
									isPlaying: true,
									tapped: {},
									play: {},
									pause: {},
									seekToSeconds: { _ in },
									endSeek: {},
									stop: {},
									currentTimeSeconds: 62,
									durationSeconds: 1000,
									progress: 0.5,
									close: {},
									topLeftButton: nil,
									overlayFactory: DefaultVodPlayerOverlayFactory(),
									products: [])
	}
}
