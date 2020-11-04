//
//  File.swift
//  
//
//  Created by Sacha on 03/09/2020.
//

import SwiftUI

struct LivePlayerInfo: View {

	@EnvironmentObject var theme: Theme
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
						ThemedText(liveStream.title)
							.foregroundColor(Color.white)
							.font(.custom(theme.fonts.regular, size: 18))
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
						ThemedText(liveStream.messageToDisplay())
							.lineLimit(5)
							.foregroundColor(Color.white)
							.font(.custom(theme.fonts.regular, size: 50))
							.transition(.opacity)
							.lineSpacing(0.1)
							.padding(.bottom, 55)

						ThemedText("Live in")
							.foregroundColor(Color.white)
							.font(.custom(theme.fonts.regular, size: 14))
							.transition(.opacity)
						LiveCountDown(date: liveStream.startDate)
							.transition(.opacity)
							.padding(.bottom, 50)
					}

					if showChat {
						Chat()
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
									ThemedText("\(liveStore.chatMessages.count)")
										.foregroundColor(.white)
										.font(.custom(theme.fonts.regular, size: 14))
								}
							}
							.buttonStyle(PlainButtonStyle())
							.padding(.vertical, 9)
							.padding(.trailing, 9)
						}
						Spacer()
						if !showChat {
							Image("Person", bundle: .module)
							ThemedText("518k")
								.transition(.opacity)
								.foregroundColor(.white)
								.font(.custom(theme.fonts.regular, size: 14))
						} else {
							HStack {
								ZStack(alignment: .leading) {
									if chatText.isEmpty {
										Text("Type a message")
											.foregroundColor(theme.lightForegroundColor)
											.opacity(0.75)
											.font(.custom(theme.fonts.light, size: 14))
									}
									TextField("", text: $chatText, onCommit: {
										_ = liveStore.send(message: chatText, for: liveStream)
										chatText = ""
									})
									.font(.custom(theme.fonts.light, size: 14))
									.foregroundColor(theme.lightForegroundColor)
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
									.stroke(theme.lightForegroundColor.opacity(0.5), lineWidth: 1)
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
	static var previews: some View {
		GeometryReader { proxy in
			Group {
				LivePlayerInfo(liveStream: fakeLivestream(with: .idle), close: {}, proxy: proxy)
				LivePlayerInfo(liveStream: fakeLivestream(with: .waitingRoom), close: {}, proxy: proxy)
				LivePlayerInfo(liveStream: fakeLivestream(with: .broadcasting), close: {}, proxy: proxy)
				LivePlayerInfo(liveStream: fakeLivestream(with: .finished), close: {}, proxy: proxy)
			}
		}
	}
}
