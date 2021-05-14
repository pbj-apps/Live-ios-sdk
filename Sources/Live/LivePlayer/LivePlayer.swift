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
import AVKit

let sharedKeyboardResponder = KeyboardResponder()

public class LivePlayerViewModel: ObservableObject {
	
	@Published public var liveStream: LiveStream
	let productRepository: ProductRepository
	@Published public var products: [Product]
	@Published public var currentlyFeaturedProducts: [Product]
	@Published var showProducts = false
	//    @Published var showCurrentlyFeaturedProducts = false
	private var cancellables = Set<AnyCancellable>()
	
	public init(liveStream: LiveStream, productRepository: ProductRepository) {
		self.liveStream = liveStream
		self.products = []
		self.currentlyFeaturedProducts = []
		self.productRepository = productRepository
		self.fetchProducts()
		self.fetchCurrentlyFeaturedProducts()
	}
	
	public func fetchProducts() {
		productRepository.fetchProducts(for: liveStream)
			.then { [unowned self] fetchedProducts in
				withAnimation {
					self.products = fetchedProducts
					//					self.showProducts  = true
				}
			}
			.sink()
			.store(in: &cancellables)
	}
	
	public func fetchCurrentlyFeaturedProducts() {
		productRepository.fetchCurrentlyFeaturedProducts(for: liveStream)
			.then { [unowned self] fetchedProducts in
				withAnimation {
					self.currentlyFeaturedProducts = fetchedProducts
					//                    self.showProducts  = true
				}
			}
			.sink()
			.store(in: &cancellables)
	}
	
	public func registerForProductHighlights() {
		productRepository.registerForProductHighlights(for: liveStream)
			.receive(on: RunLoop.main)
			.sink {  [unowned self] productUpdate in
				print(productUpdate)
				withAnimation {
					self.currentlyFeaturedProducts = productUpdate.products
				}
				//            self.showCurrentlyFeaturedProducts  = true
			}.store(in: &cancellables)
	}
	
	public func unRegisterForProductHighlights() {
		productRepository.unRegisterProductHighlights(for: liveStream)
	}
}

public struct LivePlayer: View {
	
	@ObservedObject var viewModel: LivePlayerViewModel
	
	// Chat
	let isChatEnabled: Bool
	let chatMessages: [ChatMessage]
	let fetchMessages: () -> Void
	let sendMessage: (String, String?) -> Void
	let isInGuestMode: Bool
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
	@State var chatUsername: String?
	
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
		sendMessage: @escaping (String, String?) -> Void,
		
		isInGuestMode: Bool
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
		self.isInGuestMode = isInGuestMode
		
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
				ZStack {
					Color.black
					VStack {
						ActivityIndicator(isAnimating: .constant(true), style: .medium, color: UIColor.white)
						Text("Connecting to Livestream...")
							.foregroundColor(Color.white)
					}
					if let broadcastUrl = liveStream.broadcastUrl {
						LivePlayerView(broadcastUrl: broadcastUrl,
													 finishedPlaying: finishedPlaying,
													 isPlaying: isLivePlaying)
					}
				}.zIndex(2)
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
						showProducts: $viewModel.showProducts,
						isChatEnabled: isChatEnabled,
						chatMessages: chatMessages,
						fetchMessages: fetchMessages,
						sendMessage: sendMessage,
						products: viewModel.products,
						currentlyFeaturedProducts: viewModel.currentlyFeaturedProducts,
						isAllCaps: isAllCaps,
						regularFont: regularFont,
						lightFont: lightFont,
						lightForegroundColor: lightForegroundColor,
						isInGuestMode: isInGuestMode,
						chatUsername: $chatUsername,
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
		}.onAppear {
			print("On appear")
			viewModel.registerForProductHighlights()
		}
		.onDisappear {
			print("onDisappear")
			viewModel.unRegisterForProductHighlights()
		}
	}
}

struct LivePlayerView: UIViewRepresentable {
	
	let broadcastUrl: String
	let finishedPlaying: () -> Void
	let isPlaying: Bool
	
	func updateUIView(_ uiView: UIView, context: Context) {
		if isPlaying {
			// Keep close to direct as much as possible.
			context.coordinator.player?.seek(to: CMTime.positiveInfinity)
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

class LivePlayerAVPlayerView: UIView, AVPictureInPictureControllerDelegate {
	
	var finishedPlaying: () -> Void = {}

	var pictureInPictureController: AVPictureInPictureController?
	
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

		playerItem.automaticallyPreservesTimeOffsetFromLive = true
		playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true

		let player = AVQueuePlayer(playerItem: playerItem)
		playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		playerLayer?.player = player
		
		NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)),
																					 name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
																					 object: player.currentItem)

		// Enable Picture in picture (PiP) if available
		if AVPictureInPictureController.isPictureInPictureSupported() {
			pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer!)
		}
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
