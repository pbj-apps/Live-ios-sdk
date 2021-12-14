//
//  File.swift
//  
//
//  Created by Sacha on 03/09/2020.
//

import SwiftUI
import Live

struct LivePlayerInfo: View {

	// Chat
	@Binding var showProducts: Bool
	let isChatEnabled: Bool
	let chatMessages: [ChatMessage]
	let fetchMessages: () -> Void
	let sendMessage: (String, String?) -> Void
	let products: [Product]
	let currentlyFeaturedProducts: [Product]
	let isAllCaps: Bool
	let regularFont: String
	let lightFont: String
	let lightForegroundColor: Color
	let isInGuestMode: Bool
	@Binding var chatUsername: String?

	@State private var isChatShown = false
	@State private var chatText: String = ""
	@State private var showsUsernameAlert = false

	let episode: Episode
	let close: (() -> Void)?
	let proxy: GeometryProxy

	var canShowFeaturedProducts: Bool {
		return episode.status == .broadcasting && !products.isEmpty
	}

	var body: some View {
		ZStack(alignment: .top) {
			topGradient
			bottomGradient
			VStack(alignment: .leading, spacing: 0) {
				topBar
				Spacer()
				if episode.status == .idle || (episode.status == .waitingRoom && !isChatShown) {
					showDetails
				}
				if !showProducts && episode.status == .broadcasting && !currentlyFeaturedProducts.isEmpty {
					currentlyFeaturedProductsView
				}
				if canShowFeaturedProducts && showProducts {
					productsView
				}
				if canShowChat && isChatShown {
					chat
				}
				bottomBar
			}
			.padding(.bottom, bottomSpace)
		}.textFieldAlert(isPresented: $showsUsernameAlert, content: {
			TextFieldAlert(title: "Username", message: "Pick a username for your chat messages", text: self.$chatUsername)
		})
		.onAppear {
			fetchMessages()
		}
	}

	var bottomBar: some View {
		HStack {
			if canShowChat {
				chatButton
			}
			Spacer()
			if canShowChat && isChatShown {
				chatInput
					.padding(.trailing, trailingSpace)
			} else if canShowFeaturedProducts {
				productsButton
					.padding(.trailing, 16)
			}
		}
		.padding(.leading, leadingSpace)
		.frame(height: 42)
	}

	var chat: some View {
		Chat(
			chatMessages: chatMessages,
			regularFont: regularFont,
			lightFont: lightFont)
			.padding(.bottom, 15)
			.transition(.opacity)
			.padding(.leading, leadingSpace)
			.padding(.trailing, trailingSpace)
	}

	var chatButton: some View {
		Button(action: {
			withAnimation {
				isChatShown.toggle()
				showProducts = false
			}
		}) {
			Image("ChatMessageBubble", bundle: .module)
			if !isChatShown {
				UppercasedText("\(chatMessages.count)", uppercased: isAllCaps)
					.foregroundColor(.white)
					.font(.custom(regularFont, size: 14))
			}
		}
		.buttonStyle(PlainButtonStyle())
		.padding(.top, 2)
		.padding(.vertical, 9)
		.padding(.trailing, 9)
		.padding(.leading, 3)
		.opacity(showProducts ? 0.4 : 1)
	}

	var chatInput: some View {
		HStack {
			ZStack(alignment: .leading) {
				if chatText.isEmpty {
					Text("Type a message")
						.foregroundColor(lightForegroundColor)
						.opacity(0.75)
						.font(.custom(lightFont, size: 14))
				}
				TextField("", text: $chatText, onCommit: {
					trySendChatMessage()
				})
				.font(.custom(lightFont, size: 14))
				.foregroundColor(lightForegroundColor)
				.simultaneousGesture(TapGesture())
			}
			Button(action: {
				if !chatText.isEmpty {
					trySendChatMessage()
				}
			}) {
				Image("Send", bundle: .module)
					.opacity(chatText.isEmpty ? 0.5 : 1)
			}
		}
		.padding(9)
		.overlay(
			RoundedRectangle(cornerRadius: 8)
				.stroke(lightForegroundColor.opacity(0.5), lineWidth: 1)
		)
	}

	private func trySendChatMessage() {
		if isInGuestMode && (chatUsername == nil || chatUsername?.isEmpty == true) {
			showsUsernameAlert = true
		} else {
			sendMessage(chatText, chatUsername)
			chatText = ""
		}
	}

	var showDetails: some View {
		VStack(alignment: .leading) {
			UppercasedText(episode.messageToDisplay(), uppercased: isAllCaps)
				.foregroundColor(Color.white)
				.font(.custom(regularFont, size: 50))
				.minimumScaleFactor(0.4)
				.lineSpacing(0.1)
				.frame(maxHeight: proxy.size.height / 2)
				.fixedSize(horizontal: false, vertical: true)
				.padding(.bottom, 55)
			UppercasedText("Live in", uppercased: isAllCaps)
				.foregroundColor(Color.white)
				.font(.custom(regularFont, size: 14))
			LiveCountDown(
				date: episode.startDate,
				isAllCaps: isAllCaps,
				lightForegroundColor: lightForegroundColor,
				regularFont: regularFont)
				.padding(.bottom, 50)
		}
		.transition(.opacity)
		.padding(.leading, leadingSpace)
		.padding(.trailing, trailingSpace)
	}

	var productsButton: some View {
		Button(action: {
			withAnimation {
				showProducts.toggle()
			}
		}) {
			Image("ProductsIcon", bundle: .module)
			UppercasedText("\(products.count)", uppercased: isAllCaps)
				.foregroundColor(.white)
				.font(.custom(regularFont, size: 14))
		}
		.buttonStyle(PlainButtonStyle())
		.padding(.vertical, 9)
		.transition(.opacity)
	}

	var topGradient: some View {
		Rectangle()
			.fill(LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .top, endPoint: .bottom))
			.opacity(0.7)
			.frame(height: 150)
			.drawingGroup()
	}

	var bottomGradient: some View {
		Rectangle()
			.fill(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
			.padding(.top, 90)
			.opacity(0.7)
			.drawingGroup()
	}

	var topBar: some View {
		ZStack {
			HStack {
				LiveIndicatorView(isLive: episode.status == .broadcasting)
				Spacer()
				closeButton
			}
			HStack {
				Spacer()
				UppercasedText(episode.title, uppercased: isAllCaps)
					.foregroundColor(Color.white)
					.font(.custom(regularFont, size: 18))
					.multilineTextAlignment(TextAlignment.center)
				Spacer()
			}.padding(.horizontal, 40)
		}
		.padding(.leading, leadingSpace)
		.padding(.trailing, trailingSpace)
		.padding(.top, topSpace)
	}

	var closeButton: some View {
		Button(action: {
			withAnimation {
				close?()
			}
		}) {
			Image(systemName: "xmark")
				.font(Font.system(size: 17, weight: .semibold))
				.foregroundColor(Color.white)
				.frame(height: 13)
				.padding(.horizontal, 7)
				.padding(.bottom, 2)
		}
	}

	var currentlyFeaturedProductsView: some View {
		ProductsCarrousel(
			products: currentlyFeaturedProducts,
			fontName: regularFont,
			leadingSpace: max(proxy.safeAreaInsets.leading, 11),
			onTapProduct: { product in
				if let productLink = product.link {
					UIApplication.shared.open(productLink, options: [:], completionHandler: nil)
				}
			})
			.padding(.bottom, 6)
	}

	var productsView: some View {
		ProductsCarrousel(
			products: products,
			fontName: regularFont,
			leadingSpace: max(proxy.safeAreaInsets.leading, 11),
			onTapProduct: { product in
				if let productLink = product.link {
					UIApplication.shared.open(productLink, options: [:], completionHandler: nil)
				}
			})
			.padding(.bottom, 6)
	}

	// When rotating landscape, safeAreaInsets.top == 0.
	// that's why we have to check.
	var topSpace: CGFloat {
		let topSafeArea = proxy.safeAreaInsets.top
		if topSafeArea > 0 {
			return topSafeArea
		}
		return 20
	}

	var leadingSpace: CGFloat {
		max(proxy.safeAreaInsets.leading, 20)
	}

	var bottomSpace: CGFloat {
		max(proxy.safeAreaInsets.bottom, 20)
	}

	var trailingSpace: CGFloat {
		max(proxy.safeAreaInsets.trailing, 20)
	}

	var canShowChat: Bool {
		isChatEnabled && (episode.status == .waitingRoom || episode.status == .broadcasting)
	}
}

public func fakeEpisode(with state: Status) -> Episode {
	return Episode(id: "id",
										title: "Running with Chris",
										description: "Aka bok celery chinese greater kuka kurrat moth onion polk radish sprouts yardlong.",
										duration: 12,
										status: state,
										broadcastUrl: nil,
										instructor: User(
											id: "abc",
											firstname: "firstname",
											lastname: "lastname",
											email: "email",
											username: "username",
											hasAnsweredSurvey: true,
											avatarUrl: nil),
										previewImageUrl:
											"https://image.shutterstock.com/image-photo/gopher-stands-on-hind-legs-600w-1447516073.jpg",
										previewImageUrlFullSize: "https://image.shutterstock.com/image-photo/gopher-stands-on-hind-legs-600w-1447516073.jpg",
										previewVideoUrl: nil,
										startDate: Date().addingTimeInterval(10000),
										endDate: Date(),
										waitingRomDescription: "WaitingRoom details",
										isPushNotificationReminderSet: false)
}

struct LivePlayerInfo_Previews: PreviewProvider {

	static func info(with status: Status, proxy: GeometryProxy) -> LivePlayerInfo {
		LivePlayerInfo(
			showProducts: .constant(true),
			isChatEnabled: true,
			chatMessages: [],
			fetchMessages: {},
			sendMessage: { _, _ in },
			products: [],
			currentlyFeaturedProducts: [],
			isAllCaps: false,
			regularFont: "HelveticaNeue",
			lightFont: "Helvetica-Light",
			lightForegroundColor: .white,
			isInGuestMode: false,
			chatUsername: .constant("John"),
			episode: fakeEpisode(with: status), close: { }, proxy: proxy)
	}

	static var previews: some View {
		GeometryReader { proxy in
			Group {
				info(with: .idle, proxy: proxy)
				info(with: .waitingRoom, proxy: proxy)
				info(with: .broadcasting, proxy: proxy)
				info(with: .finished, proxy: proxy)
			}
		}
	}
}
