//
//  LivePlayer.swift
//  Live
//
//  Created by Thibault Gauche on 27/07/2020.
//  Copyright © 2020 PBJApps. All rights reserved.
//

import SwiftUI
import AVFoundation
import Combine
import AVKit
import Live

let sharedKeyboardResponder = KeyboardResponder()

public class DefaultProductCardViewFactory: ProductCardViewFactory {
	
	public func makeProductCard(product: Product) -> some View {
		ProductComponent(product: product, fontName: "", onTap: {})
	}
	
	public init() {}
}

public class DefaultLivePlayerInfoHeaderFactory: LivePlayerInfoHeaderFactory {
	
	public func makeLivePlayerInfoHeaderView(episode: Episode, regularFont: String, close: @escaping () -> Void) -> some View {
		LivePlayerInfoHeader(title: episode.title,
												 isLive: episode.status == .broadcasting,
												 regularFont: "",
												 close: close)
	}
	
	public init() {}
}




public protocol ProductCardViewFactory {
	associatedtype ProductCardView: View
	func makeProductCard(product: Product) -> ProductCardView
}


public protocol LivePlayerInfoHeaderFactory {
	associatedtype LivePlayerInfoHeaderView: View
	func makeLivePlayerInfoHeaderView(episode: Episode,
																		regularFont: String,
																		close: @escaping () -> Void) -> LivePlayerInfoHeaderView
}


public struct LivePlayer<PVF: ProductCardViewFactory,
												 LPIHF: LivePlayerInfoHeaderFactory>: View {
	
	@StateObject var viewModel: LivePlayerViewModel
	
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
	let defaultsToAspectRatioFit: Bool
	
	var episode: Episode {
		return viewModel.episode
	}
	
	let nextEpisode: Episode?
	let close: (() -> Void)?
	
	@ObservedObject private var keyboard = sharedKeyboardResponder
	@State private var isLivePlaying = true
	@State var showInfo = true
	@State var chatUsername: String?
	
	private let productCardViewFactory: PVF
	private let livePlayerInfoHeaderFactory: LPIHF
	
	public init (
		episode: Episode,
		liveRepository: LiveRepository = LiveSDKInstance.shared,
		productRepository: ProductRepository = LiveSDKInstance.shared,
		nextEpisode: Episode? = nil,
		close: (() -> Void)? = nil,
		isAllCaps: Bool = false,
		regularFont: String = "HelveticaNeue",
		lightFont: String = "Helvetica-Light",
		lightForegroundColor: Color = Color.white,
		imagePlaceholderColor: Color = Color(#colorLiteral(red: 0.9499530196, green: 0.9499530196, blue: 0.9499530196, alpha: 1)),
		accentColor: Color = Color.black,
		remindMeButtonBackgroundColor: Color =  Color.white,
		defaultsToAspectRatioFit: Bool = true,
		// Chat
		isChatEnabled: Bool = false,
		chatMessages: [ChatMessage] = [],
		fetchMessages: @escaping () -> Void = {},
		sendMessage: @escaping (String, String?) -> Void = { _, _ in},
		isInGuestMode: Bool = true,
		productCardViewFactory: PVF,
		livePlayerInfoHeaderFactory: LPIHF
	) {
		_viewModel =  StateObject(wrappedValue: LivePlayerViewModel(episode: episode, liveRepository: liveRepository, productRepository: productRepository))
		self.nextEpisode = nextEpisode
		self.close = close
		
		self.isAllCaps = isAllCaps
		self.regularFont = regularFont
		self.lightFont = lightFont
		self.lightForegroundColor = lightForegroundColor
		self.imagePlaceholderColor = imagePlaceholderColor
		self.accentColor = accentColor
		self.remindMeButtonBackgroundColor = remindMeButtonBackgroundColor
		self.defaultsToAspectRatioFit = defaultsToAspectRatioFit
		
		self.isChatEnabled = isChatEnabled
		self.chatMessages = chatMessages
		self.fetchMessages = fetchMessages
		self.sendMessage = sendMessage
		self.isInGuestMode = isInGuestMode
		self.productCardViewFactory = productCardViewFactory
		self.livePlayerInfoHeaderFactory = livePlayerInfoHeaderFactory
	}
	
	public init (
		episode: Episode,
		liveRepository: LiveRepository = LiveSDKInstance.shared,
		productRepository: ProductRepository = LiveSDKInstance.shared,
		nextEpisode: Episode? = nil,
		close: (() -> Void)? = nil,
		isAllCaps: Bool = false,
		regularFont: String = "HelveticaNeue",
		lightFont: String = "Helvetica-Light",
		lightForegroundColor: Color = Color.white,
		imagePlaceholderColor: Color = Color(#colorLiteral(red: 0.9499530196, green: 0.9499530196, blue: 0.9499530196, alpha: 1)),
		accentColor: Color = Color.black,
		remindMeButtonBackgroundColor: Color =  Color.white,
		defaultsToAspectRatioFit: Bool = true,
		// Chat
		isChatEnabled: Bool = false,
		chatMessages: [ChatMessage] = [],
		fetchMessages: @escaping () -> Void = {},
		sendMessage: @escaping (String, String?) -> Void = { _, _ in},
		isInGuestMode: Bool = true
	) where PVF == DefaultProductCardViewFactory, LPIHF == DefaultLivePlayerInfoHeaderFactory {
		_viewModel =  StateObject(wrappedValue: LivePlayerViewModel(episode: episode, liveRepository: liveRepository, productRepository: productRepository))
		self.nextEpisode = nextEpisode
		self.close = close
		
		self.isAllCaps = isAllCaps
		self.regularFont = regularFont
		self.lightFont = lightFont
		self.lightForegroundColor = lightForegroundColor
		self.imagePlaceholderColor = imagePlaceholderColor
		self.accentColor = accentColor
		self.remindMeButtonBackgroundColor = remindMeButtonBackgroundColor
		self.defaultsToAspectRatioFit = defaultsToAspectRatioFit
		
		self.isChatEnabled = isChatEnabled
		self.chatMessages = chatMessages
		self.fetchMessages = fetchMessages
		self.sendMessage = sendMessage
		self.isInGuestMode = isInGuestMode
		self.productCardViewFactory = DefaultProductCardViewFactory()
		self.livePlayerInfoHeaderFactory = DefaultLivePlayerInfoHeaderFactory()
	}

	public var body: some View {
		GeometryReader { proxy in
			ZStack {
				Color.black
					.zIndex(0)
				ImageBackground(url: viewModel.episode.previewImageUrl)
					.frame(width: proxy.size.width ?? UIScreen.main.bounds.size.width)
					.zIndex(1)
				switch episode.status {
				case .idle, .waitingRoom:
					if let previewVideoUrl = episode.previewVideoUrl {
						VideoPlayer(
							episode: episode,
							url: previewVideoUrl,
							looping: true,
							isPlaying: true,
							isLive: true,
							isMuted: false,
							allowsPictureInPicture: false,
							aspectRatioFit: false,
							elapsedTime: nil)
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
						if let broadcastUrl = episode.broadcastUrl {
							VideoPlayer(episode: episode,
													url: broadcastUrl,
													looping: false,
													isPlaying: isLivePlaying,
													isLive: true,
													isMuted: false,
													allowsPictureInPicture: true,
													aspectRatioFit: defaultsToAspectRatioFit,
													elapsedTime: episode.timeElapsed())
						}
					}.zIndex(2)
				case .finished:
					LivePlayerFinishedStateOverlay(
						nextEpisode: nextEpisode,
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
				if episode.status != .finished { //} && liveStream.status != .idle {
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
								episode: episode,
								close: {
									isLivePlaying = false
									close?()
								},
								proxy: proxy,
								productCardViewFactory: productCardViewFactory,
								livePlayerInfoHeaderFactory: livePlayerInfoHeaderFactory)
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
			
		}.ignoresSafeArea(.keyboard, edges: .bottom)
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
