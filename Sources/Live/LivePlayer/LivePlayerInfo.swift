//
//  File.swift
//  
//
//  Created by Sacha on 03/09/2020.
//

import SwiftUI

struct LivePlayerInfo: View {

	// Chat
	let isChatEnabled: Bool
	let chatMessages: [ChatMessage]
	let fetchMessages: () -> Void
	let sendMessage: (String) -> Void

	let isAllCaps: Bool
	let regularFont: String
	let lightFont: String
	let lightForegroundColor: Color

	@State private var isChatShown = false
	@State private var chatText: String = ""

	let liveStream: LiveStream
	let close: (() -> Void)?
	let proxy: GeometryProxy?

	var body: some View {
		ZStack(alignment: .top) {
			Rectangle()
				.fill(LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .top, endPoint: .bottom))
				.opacity(0.7)
				.frame(height: 150)
				.drawingGroup()
			Rectangle()
				.fill(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
				.padding(.top, 90)
				.opacity(0.7)
				.drawingGroup()
			HStack {
				VStack(alignment: .leading, spacing: 0) {
					HStack {
						LiveIndicatorView(isLive: liveStream.status == .broadcasting)
						Spacer()
						UppercasedText(liveStream.title, uppercased: isAllCaps)
							.foregroundColor(Color.white)
							.font(.custom(regularFont, size: 18))
						Spacer()
						Button(action: {
							withAnimation {
								close?()
							}
						}) {
							Image(systemName: "xmark")
								.resizable()
								.scaledToFit()
								.foregroundColor(Color.white)
								.frame(height: 13)
						}
					}
					.padding(.top, topSpace)
					Spacer()

					if liveStream.status == .idle || (liveStream.status == .waitingRoom && !isChatShown) {
						UppercasedText(liveStream.messageToDisplay(), uppercased: isAllCaps)
							.lineLimit(5)
							.foregroundColor(Color.white)
							.font(.custom(regularFont, size: 50))
							.transition(.opacity)
							.lineSpacing(0.1)
							.padding(.bottom, 55)

						UppercasedText("Live in", uppercased: isAllCaps)
							.foregroundColor(Color.white)
							.font(.custom(regularFont, size: 14))
							.transition(.opacity)
						LiveCountDown(
							date: liveStream.startDate,
							isAllCaps: isAllCaps,
							lightForegroundColor: lightForegroundColor,
							regularFont: regularFont)

							.transition(.opacity)
							.padding(.bottom, 50)
					}

					if canShowChat && isChatShown {
						Chat(
							chatMessages: chatMessages,
							regularFont: regularFont,
							lightFont: lightFont)
							.padding(.bottom, 15)
							.transition(.opacity)
					}
					HStack {
						if canShowChat {
							Button(action: {
								withAnimation {
									isChatShown.toggle()
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
							.padding(.vertical, 9)
							.padding(.trailing, 9)
						}
						Spacer()
						if canShowChat && isChatShown {
							HStack {
								ZStack(alignment: .leading) {
									if chatText.isEmpty {
										Text("Type a message")
											.foregroundColor(lightForegroundColor)
											.opacity(0.75)
											.font(.custom(lightFont, size: 14))
									}
									TextField("", text: $chatText, onCommit: {
										sendMessage(chatText)
										chatText = ""
									})
									.font(.custom(lightFont, size: 14))
									.foregroundColor(lightForegroundColor)
									.simultaneousGesture(TapGesture())
								}
								Button(action: {
									if !chatText.isEmpty {
										sendMessage(chatText)
										chatText = ""
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
						} else {
							// Hide for now as we don't have this data yet.
//							Image("Person", bundle: .module)
//							UppercasedText("518k", uppercased: isAllCaps)
//								.transition(.opacity)
//								.foregroundColor(.white)
//								.font(.custom(regularFont, size: 14))
						}
					}
				}
				.padding(.leading, leadingSpace)
				.padding(.trailing, trailingSpace)
				.padding(.bottom, bottomSpace)
			}
		}
		.onAppear {
			fetchMessages()
		}
	}
	
	// When rotating landscape, safeAreaInsets.top == 0.
	// that's why we have to check.
	var topSpace: CGFloat {
		max(proxy?.safeAreaInsets.top ?? 0, 20)
	}
	
	var leadingSpace: CGFloat {
		max(proxy?.safeAreaInsets.leading ?? 0, 20)
	}
	
	var bottomSpace: CGFloat {
		max(proxy?.safeAreaInsets.bottom ?? 0, 20)
	}

	
	var trailingSpace: CGFloat {
		max(proxy?.safeAreaInsets.trailing ?? 0, 20)
	}

	var canShowChat: Bool {
		isChatEnabled && (liveStream.status == .waitingRoom || liveStream.status == .broadcasting)
	}
}

public func fakeLivestream(with state: LiveStreamStatus) -> LiveStream {
	return LiveStream(id: "id",
										title: "Running with Chris",
										description: "Aka bok celery chinese greater kuka kurrat moth onion polk radish sprouts yardlong.",
										duration: 12,
										status: state,
										showId: "showId",
										broadcastUrl: nil,
										chatMode: ChatMode.disabled,
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
										waitingRomDescription: "WaitingRoom details")
}

struct LivePlayerInfo_Previews: PreviewProvider {

	static func info(with status: LiveStreamStatus, proxy: GeometryProxy) -> LivePlayerInfo {
		LivePlayerInfo(
			isChatEnabled: true,
			chatMessages: [],
			fetchMessages: {},
			sendMessage: { _ in },
			isAllCaps: false,
			regularFont: "HelveticaNeue",
			lightFont: "Helvetica-Light",
			lightForegroundColor: .white,
			liveStream: fakeLivestream(with: status), close: { }, proxy: proxy)
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
