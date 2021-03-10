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
import Combine

let sharedKeyboardResponder = KeyboardResponder()

public class LivePlayerViewModel: ObservableObject {

	@Published public var liveStream: LiveStream
	let productRepository: ProductRepository
	@Published public var products: [Product]
	private var cancellables = Set<AnyCancellable>()

	public init(liveStream: LiveStream, productRepository: ProductRepository) {
		self.liveStream = liveStream
		self.products = []
		self.productRepository = productRepository
		fetchProducts()
	}

	public func fetchProducts() {
		productRepository.fetchProducts(for: liveStream)
			.then { [unowned self] fetchedProducts in
				withAnimation {
					self.products = fetchedProducts
				}
			}
			.sink()
			.store(in: &cancellables)
	}
}

public struct LivePlayer: View {

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

	var liveStream: LiveStream {
		return viewModel.liveStream
	}

	let nextLiveStream: LiveStream?
	let finishedPlaying: () -> Void
	let close: (() -> Void)?
	let proxy: GeometryProxy?

	@ObservedObject private var keyboard = sharedKeyboardResponder
	@ObservedObject private var backgroundImage: FetchImage
	@State private var isLivePlaying = true
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
				Color.black
					.zIndex(0)
				ImageBackground(image: backgroundImage)
					.frame(width: proxy?.size.width ?? UIScreen.main.bounds.size.width)
					.zIndex(1)
				switch liveStream.status {
				case .idle, .waitingRoom:
					if let previewVideoUrl = liveStream.previewVideoUrl {
						VideoPlayer(url: previewVideoUrl, looping: true, isPlaying: true)
							.zIndex(2)
					}
				case .broadcasting:
					if let broadcastUrl = liveStream.broadcastUrl {
						Color.black
						ActivityIndicator(isAnimating: .constant(true), style: .large, color: UIColor.white)
						LivePlayerView(broadcastUrl: broadcastUrl,
													 finishedPlaying: finishedPlaying,
													 isPlaying: isLivePlaying)
							.zIndex(2)
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
						.zIndex(3)
				}
				if liveStream.status != .finished { //} && liveStream.status != .idle {
					if showInfo {
						LivePlayerInfo(
							isChatEnabled: isChatEnabled,
							chatMessages: chatMessages,
							fetchMessages: fetchMessages,
							sendMessage: sendMessage,
							featuredProducts: viewModel.products,
							isAllCaps: isAllCaps,
							regularFont: regularFont,
							lightFont: lightFont,
							lightForegroundColor: lightForegroundColor,
							liveStream: liveStream,
							close: {
								isLivePlaying = false
								close?()
							},
							proxy: proxy)
							.transition(.opacity)
							.padding(.bottom, keyboard.currentHeight)
							.zIndex(4)
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
}

struct LivePlayerView: UIViewRepresentable {

	let broadcastUrl: String
	let finishedPlaying: () -> Void
	let isPlaying: Bool

	func updateUIView(_ uiView: UIView, context: Context) {
		if isPlaying {
			context.coordinator.player?.play()
		} else {
			context.coordinator.player?.pause()
		}
	}

	func makeUIView(context: Context) -> UIView {
		let livePlayerView = LivePlayerAVPlayerView(
			urlString: broadcastUrl,
			finishedPlaying: finishedPlaying)
		context.coordinator.player = livePlayerView.player
		return livePlayerView
	}

	func makeCoordinator() -> Coordinator {
		return Coordinator()
	}

	public class Coordinator {
		var isPlaying: Bool = true
		var player: AVPlayer?
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

	convenience init(urlString: String,
									 finishedPlaying: @escaping () -> Void) {
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
		GeometryReader { _ in
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
