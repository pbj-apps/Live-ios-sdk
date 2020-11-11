//
//  LivePlayerFinishedStateOverlay.swift
//
//
//  Created by Sacha on 04/09/2020.
//

import SwiftUI
import FetchImage

struct LivePlayerFinishedStateOverlay: View {

	@EnvironmentObject var theme: Theme
	let nextLiveStream: LiveStream?
	let close: (() -> Void)?
	@ObservedObject private var instructorAvatar: FetchImage
	let proxy: GeometryProxy?

	init(nextLiveStream: LiveStream?, proxy: GeometryProxy?, close: (() -> Void)?) {
		self.nextLiveStream = nextLiveStream
		self.proxy = proxy
		self.close = close

		if let url = URL(string: nextLiveStream?.instructor.avatarUrl ?? "") {
			instructorAvatar = FetchImage(url: url)
		} else {
			instructorAvatar = FetchImage(url: URL(string: "http://pbj.studio")!)
		}
	}

	var body: some View {
		ZStack(alignment: .top) {
			Color.black
				.opacity(0.7)
			VStack(spacing: 0) {
				HStack {
					Spacer()
					ThemedText("Thanks for watching!")
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
				.padding(.horizontal, 30)

				Spacer()
				if let nextLiveStream = nextLiveStream {
					VStack(spacing: 0) {
						ThemedText("Next up")
							.foregroundColor(Color.white)
							.font(.custom(theme.fonts.regular, size: 18))
							.padding(.bottom, 10)
						ThemedText(nextLiveStream.title)
							.foregroundColor(Color.white)
							.font(.custom(theme.fonts.regular, size: 39))
							.multilineTextAlignment(.center)
							.padding(.bottom, 12)
						HStack(spacing: 0) {
							ImageView(image: instructorAvatar)
								.frame(width: 30, height: 30)
								.clipShape(RoundedRectangle(cornerRadius: 7.43))
								.padding(.trailing, 10)
							ThemedText("with ")
								.foregroundColor(Color.white)
								.font(.custom(theme.fonts.light, size: 18))
							ThemedText("\(nextLiveStream.instructor.firstname) \(nextLiveStream.instructor.lastname)")
								.foregroundColor(Color.white)
								.font(.custom(theme.fonts.regular, size: 18))
						}
						.padding(.bottom, 10)
						LiveCountDown(date: nextLiveStream.startDate)

					}.padding(.horizontal, 60)
					Spacer()
					Button(action: {}) {
						RemindMeButton()
							.padding(.horizontal, 23)
					}
				}
			}
			.padding(.top, proxy?.safeAreaInsets.top ?? 0)
			.padding(.bottom, (proxy?.safeAreaInsets.bottom != nil) ? proxy!.safeAreaInsets.bottom + 20 : 0)
		}
	}
}
