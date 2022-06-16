//
//  VodPlayer.swift
//  
//
//  Created by Sacha on 29/10/2021.
//

import SwiftUI
import AVFoundation
import Live

public struct VodPlayer<OverlayFactory: VodPlayerOverlayFactory>: View {
	
	@StateObject private var viewModel: VodPlayerViewModel
	
	private let topLeftButton: AnyView?
	private let close: () -> Void
	private let didPlay: (() -> Void)?
	private let overlayFactory: OverlayFactory
	
	public init(url: URL,
							close: @escaping () -> Void,
							didPlay: (() -> Void)? = nil,
							topLeftButton: AnyView? = nil,
							overlayFactory: OverlayFactory) {
		self._viewModel = StateObject(wrappedValue: VodPlayerViewModel(url: url, didPlay: didPlay))
		self.close = close
		self.didPlay = didPlay
		self.topLeftButton = topLeftButton
		self.overlayFactory = overlayFactory
	}
	
	public init(video: VodVideo,
							close: @escaping () -> Void,
							didPlay: (() -> Void)? = nil,
							topLeftButton: AnyView? = nil,
							overlayFactory: OverlayFactory) {
		self._viewModel = StateObject(wrappedValue: VodPlayerViewModel(video: video, didPlay: didPlay))
		self.close = close
		self.didPlay = didPlay
		self.topLeftButton = topLeftButton
		self.overlayFactory = overlayFactory
	}
	
	public init(url: URL,
							close: @escaping () -> Void,
							didPlay: (() -> Void)? = nil,
							topLeftButton: AnyView? = nil) where OverlayFactory == DefaultVodPlayerOverlayFactory {
		self._viewModel = StateObject(wrappedValue: VodPlayerViewModel(url: url, didPlay: didPlay))
		self.close = close
		self.didPlay = didPlay
		self.topLeftButton = topLeftButton
		self.overlayFactory = DefaultVodPlayerOverlayFactory()
	}
	
	public init(video: VodVideo,
							close: @escaping () -> Void,
							didPlay: (() -> Void)? = nil,
							topLeftButton: AnyView? = nil) where OverlayFactory == DefaultVodPlayerOverlayFactory {
		self._viewModel = StateObject(wrappedValue: VodPlayerViewModel(video: video, didPlay: didPlay))
		self.close = close
		self.didPlay = didPlay
		self.topLeftButton = topLeftButton
		self.overlayFactory = DefaultVodPlayerOverlayFactory()
	}
	
	public var body: some View {
		VodPlayerView(
			player: viewModel.player,
			showsControls: viewModel.showsControls,
			isPlaying: viewModel.isPlaying,
			tapped: viewModel.tapped,
			play: viewModel.play,
			pause: viewModel.pause,
			seekToSeconds: viewModel.seekToSeconds,
			endSeek: viewModel.endSeek,
			stop: viewModel.stop,
			currentTimeSeconds: viewModel.currentTimeSeconds,
			durationSeconds: viewModel.durationSeconds,
			progress: viewModel.progress,
			close: close,
			topLeftButton: topLeftButton,
			overlayFactory: overlayFactory,
			products: viewModel.products)
	}
}

struct VodPlayer_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			VodPlayer(url: URL(string: "https://www.test.com/video")!, close: {})
			VodPlayer(url: URL(string: "https://www.test.com/video")!,
								close: {},
								overlayFactory: CustomVodPlayerOverlayFactory())
		}
	}
}


public class CustomVodPlayerOverlayFactory: VodPlayerOverlayFactory {
	
	public func makeVodPlayerOverlay(
		products: [Product],
		isPlaying: Bool,
		toggleOverlay: @escaping () -> Void,
		play: @escaping () -> Void,
		pause: @escaping () -> Void,
		seekToSeconds: (Double) -> Void,
		endSeek: @escaping () -> Void,
		stop: @escaping () -> Void,
		durationSeconds: Double,
		currentTimeSeconds: Double,
		progress: Float,
		close: @escaping () -> Void,
		safeAreaInsets: EdgeInsets) -> some View {
		Text("MockVodPlayerOverlayFactory")
			.foregroundColor(.white)
	}
}
