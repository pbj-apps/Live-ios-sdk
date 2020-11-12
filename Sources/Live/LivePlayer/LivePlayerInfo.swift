//
//  File.swift
//  
//
//  Created by Sacha on 03/09/2020.
//

import SwiftUI

struct LivePlayerInfo: View {

	let isAllCaps: Bool
	let regularFont: String
	let lightFont: String
	let lightForegroundColor: Color
	@EnvironmentObject var liveStore: LiveStore

	@State private var showChat = false
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
					.padding(.top, proxy?.safeAreaInsets.top ?? 0)
					Spacer()
					if (liveStream.status == .idle || liveStream.status == .waitingRoom) && !showChat {
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

					if showChat {
						Chat(regularFont: regularFont,
								 lightFont: lightFont)
							.padding(.bottom, 15)
							.environmentObject(liveStore)
							.transition(.opacity)
					}
					HStack {
						if liveStore.isChatEnabled {
							Button(action: {
								withAnimation {
									showChat.toggle()
								}
							}) {
								Image("ChatMessageBubble", bundle: .module)
								if !showChat {
									UppercasedText("\(liveStore.chatMessages.count)", uppercased: isAllCaps)
										.foregroundColor(.white)
										.font(.custom(regularFont, size: 14))
								}
							}
							.buttonStyle(PlainButtonStyle())
							.padding(.vertical, 9)
							.padding(.trailing, 9)
						}
						Spacer()
						if !showChat {
							Image("Person", bundle: .module)
							UppercasedText("518k", uppercased: isAllCaps)
								.transition(.opacity)
								.foregroundColor(.white)
								.font(.custom(regularFont, size: 14))
						} else {
							HStack {
								ZStack(alignment: .leading) {
									if chatText.isEmpty {
										Text("Type a message")
											.foregroundColor(lightForegroundColor)
											.opacity(0.75)
											.font(.custom(lightFont, size: 14))
									}
									TextField("", text: $chatText, onCommit: {
										_ = liveStore.send(message: chatText, for: liveStream)
										chatText = ""
									})
									.font(.custom(lightFont, size: 14))
									.foregroundColor(lightForegroundColor)
									.simultaneousGesture(TapGesture())
								}
								Button(action: {
									if !chatText.isEmpty {
										_ = liveStore.send(message: chatText, for: liveStream)
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
						}
					}
				}
				.padding(.horizontal, 20)
				.padding(.bottom, (proxy == nil) ? 0 : (proxy!.safeAreaInsets.bottom != 0) ? proxy!.safeAreaInsets.bottom : 20)
			}
		}
		.onAppear {
			liveStore.fetchMessages(for: liveStream)
		}
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
											firstname: "firstname",
											lastname: "lastname",
											email: "email",
											username: "username",
											hasAnsweredSurvey: true,
											avatarUrl: nil),
										previewImageUrl:
											"https://image.shutterstock.com/image-photo/gopher-stands-on-hind-legs-600w-1447516073.jpg",
										previewVideoUrl: nil,
										startDate: Date().addingTimeInterval(10000),
										endDate: Date(),
										waitingRomDescription: "WaitingRoom details")
}

struct LivePlayerInfo_Previews: PreviewProvider {

	static func info(with status: LiveStreamStatus, proxy: GeometryProxy) -> LivePlayerInfo {
		LivePlayerInfo(
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
				info(with:.waitingRoom, proxy: proxy)
				info(with: .broadcasting, proxy: proxy)
				info(with: .finished, proxy: proxy)
			}
		}
	}
}
