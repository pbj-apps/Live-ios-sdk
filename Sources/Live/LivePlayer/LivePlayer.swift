//
//  LivePlayer.swift
//  Live
//
//  Created by Thibault Gauche on 27/07/2020.
//  Copyright © 2020 PBJApps. All rights reserved.
//

import SwiftUI
import FetchImage
import AVFoundation

public struct LivePlayer: View, Equatable {

	@ObservedObject var viewModel: LivePlayerViewModel

	// Chat
	let isChatEnabled: Bool
	let chatMessages: [ChatMessage]
	let fetchMessages: () -> Void
	let sendMessage: (String) -> Void

	let isAllCaps: Bool
	let regularFont: String
	let lightFont: String
	let lightForegroundColor: Color
	let imagePlaceholderColor: Color
	let accentColor: Color
	let remindMeButtonBackgroundColor: Color

//	let liveStream: LiveStream
	var liveStream: LiveStream {
		return viewModel.liveStream
	}

	let nextLiveStream: LiveStream?
	let finishedPlaying: () -> Void
	let close: (() -> Void)?
	let proxy: GeometryProxy?

	@ObservedObject private var keyboard = KeyboardResponder()
	@ObservedObject private var backgroundImage: FetchImage
	@State var showInfo = true

	public init(
		viewModel: LivePlayerViewModel,
		nextLiveStream: LiveStream? = nil,
		finishedPlaying: @escaping () -> Void,
		close: (() -> Void)? = nil,
		proxy: GeometryProxy? = nil,
		isAllCaps: Bool,
		regularFont: String,
		lightFont: String,
		lightForegroundColor: Color,
		imagePlaceholderColor: Color,
		accentColor: Color,
		remindMeButtonBackgroundColor: Color,
		// Chat
		isChatEnabled: Bool,
		chatMessages: [ChatMessage],
		fetchMessages: @escaping () -> Void,
		sendMessage: @escaping (String) -> Void
		) {
//		self.liveStream = liveStream
		self.viewModel = viewModel
		self.nextLiveStream = nextLiveStream
		self.finishedPlaying = finishedPlaying
		self.close = close
		self.proxy = proxy

		self.isAllCaps = isAllCaps
		self.regularFont = regularFont
		self.lightFont = lightFont
		self.lightForegroundColor = lightForegroundColor
		self.imagePlaceholderColor = imagePlaceholderColor
		self.accentColor = accentColor
		self.remindMeButtonBackgroundColor = remindMeButtonBackgroundColor

		self.isChatEnabled = isChatEnabled
		self.chatMessages = chatMessages
		self.fetchMessages = fetchMessages
		self.sendMessage = sendMessage

		backgroundImage = FetchImage(url: URL(string: viewModel.liveStream.previewImageUrl ?? "https://")!)
	}

	public var body: some View {
			ZStack {
				ImageBackground(image: backgroundImage)
					.frame(width: proxy?.size.width ?? UIScreen.main.bounds.size.width)
					.zIndex(0)
				switch liveStream.status {
				case .idle, .waitingRoom:
					if let previewVideoUrl = liveStream.previewVideoUrl {
						VideoPlayer(url: previewVideoUrl, looping: true, isPlaying: true)
							.zIndex(1)
					}
				case .broadcasting:
					if let broadcastUrl = liveStream.broadcastUrl {
						Color.black
						ActivityIndicator(isAnimating: .constant(true), style: .large, color: UIColor.white)
						LivePlayerView(broadcastUrl: broadcastUrl, finishedPlaying: finishedPlaying)
							.zIndex(1)
					}
				case .finished:
					LivePlayerFinishedStateOverlay(
						nextLiveStream: nextLiveStream,
						proxy: proxy,
						close: close,
						regularFont: regularFont,
						lightFont: lightFont,
						isAllCaps: isAllCaps,
						imagePlaceholderColor: imagePlaceholderColor,
						lightForegroundColor: lightForegroundColor,
						accentColor: accentColor,
						remindMeButtonBackgroundColor: remindMeButtonBackgroundColor)
						.transition(.opacity)
						.zIndex(2)
				}
				if liveStream.status != .finished { //} && liveStream.status != .idle {
					if showInfo {
						LivePlayerInfo(
							isChatEnabled: isChatEnabled,
							chatMessages: chatMessages,
							fetchMessages: fetchMessages,
							sendMessage: sendMessage,
							isAllCaps: isAllCaps,
							regularFont: regularFont,
							lightFont: lightFont,
							lightForegroundColor: lightForegroundColor,
							liveStream: liveStream,
													 close: close,
													 proxy: proxy)
							.transition(.opacity)
							.padding(.bottom, keyboard.currentHeight)
							.zIndex(3)
					}
				}
			}
		.clipped()
		.edgesIgnoringSafeArea(.all)
		.onTapGesture {
			withAnimation {
				showInfo.toggle()
			}
		}
	}

	public static func == (lhs: LivePlayer, rhs: LivePlayer) -> Bool {
		lhs.liveStream.id == rhs.liveStream.id && lhs.liveStream.status == rhs.liveStream.status && lhs.liveStream.broadcastUrl == rhs.liveStream.broadcastUrl && lhs.liveStream.previewVideoUrl == rhs.liveStream.previewVideoUrl
	}

}

struct LivePlayerView: UIViewRepresentable {

	let broadcastUrl: String
	let finishedPlaying: () -> Void

	func updateUIView(_ uiView: UIView, context: Context) {
	}

	func makeUIView(context: Context) -> UIView {
		return LivePlayerAVPlayerView(urlString: broadcastUrl, finishedPlaying: finishedPlaying)
	}
}

class LivePlayerAVPlayerView: UIView {

	var finishedPlaying: () -> Void = {}

	var player: AVPlayer? {
		get {
			return playerLayer?.player
		}
		set {
			playerLayer?.player = newValue
		}
	}

	var playerLayer: AVPlayerLayer? {
		return layer as? AVPlayerLayer
	}

	override static var layerClass: AnyClass {
		return AVPlayerLayer.self
	}

	convenience init(urlString: String, finishedPlaying: @escaping () -> Void) {
		self.init(frame: .zero)
		self.finishedPlaying = finishedPlaying
		guard let url = URL(string: urlString) else {
			return
		}
		let asset = AVAsset(url: url)
		let playerItem = AVPlayerItem(asset: asset)
		let player = AVQueuePlayer(playerItem: playerItem)
		playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		playerLayer?.player = player
		player.play()

		NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)),
																					 name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
																					 object: player.currentItem)
	}

	@objc
	func playerDidFinishPlaying(note: NSNotification) {
		print("Finished Playing")
		finishedPlaying()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

struct LivePlayer_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { proxy in
//			LivePlayer(liveStream: fakeLivestream(with: .idle),
//								 nextLiveStream: nil, finishedPlaying: {}, close: {}, proxy: proxy)

//			LivePlayer(liveStream: fakeLivestream(with: .idle),
//								 nextLiveStream: nil,
//								 currentUser: nil,
//								 finishedPlaying: {}, close: {}, proxy: proxy)
//				.previewDisplayName("Idle")
//			LivePlayer(liveStream: fakeLivestream(with: .waitingRoom),
//								 nextLiveStream: nil,
//								 currentUser: nil,
//								 finishedPlaying: {}, close: {}, proxy: proxy)
//				.previewDisplayName("WaitingRoom")
//			LivePlayer(liveStream: fakeLivestream(with: .broadcasting),
//								 nextLiveStream: nil,
//								 currentUser: nil,
//								 finishedPlaying: {}, close: {}, proxy: proxy)
//				.previewDisplayName("Broadcasting")
//			LivePlayer(liveStream: fakeLivestream(with: .finished),
//								 nextLiveStream: fakeLivestream(with: .idle),
//								 currentUser: nil,
//								 finishedPlaying: {}, close: {}, proxy: proxy)
//				.previewDisplayName("Finished")
//				.environmentObject(Theme())
		}
	}
}
