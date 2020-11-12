//
//  LivePlayerFinishedStateOverlay.swift
//
//
//  Created by Sacha on 04/09/2020.
//

import SwiftUI
import FetchImage

struct LivePlayerFinishedStateOverlay: View {

	let regularFont: String
	let lightFont: String
	let isAllCaps: Bool
	let imagePlaceholderColor: Color
	let lightForegroundColor: Color
	let accentColor: Color
	let remindMeButtonBackgroundColor: Color

	let nextLiveStream: LiveStream?
	let close: (() -> Void)?
	@ObservedObject private var instructorAvatar: FetchImage
	let proxy: GeometryProxy?

	init(nextLiveStream: LiveStream?,
			 proxy: GeometryProxy?,
			 close: (() -> Void)?,
			 regularFont: String,
			 lightFont: String,
			 isAllCaps: Bool,
			 imagePlaceholderColor: Color,
			 lightForegroundColor: Color,
			 accentColor: Color,
			 remindMeButtonBackgroundColor: Color
	) {
		self.nextLiveStream = nextLiveStream
		self.proxy = proxy
		self.close = close

		self.regularFont = regularFont
		self.lightFont = lightFont
		self.isAllCaps = isAllCaps
		self.imagePlaceholderColor = imagePlaceholderColor
		self.lightForegroundColor = lightForegroundColor
		self.accentColor = accentColor
		self.remindMeButtonBackgroundColor = remindMeButtonBackgroundColor

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
					UppercasedText("Thanks for watching!", uppercased: isAllCaps)
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
				.padding(.horizontal, 30)

				Spacer()
				if let nextLiveStream = nextLiveStream {
					VStack(spacing: 0) {
						UppercasedText("Next up", uppercased: isAllCaps)
							.foregroundColor(Color.white)
							.font(.custom(regularFont, size: 18))
							.padding(.bottom, 10)
						UppercasedText(nextLiveStream.title, uppercased: isAllCaps)
							.foregroundColor(Color.white)
							.font(.custom(regularFont, size: 39))
							.multilineTextAlignment(.center)
							.padding(.bottom, 12)
						HStack(spacing: 0) {
							LiveImageView(image: instructorAvatar, placeholderColor: imagePlaceholderColor)
								.frame(width: 30, height: 30)
								.clipShape(RoundedRectangle(cornerRadius: 7.43))
								.padding(.trailing, 10)
							UppercasedText("with ", uppercased: isAllCaps)
								.foregroundColor(Color.white)
								.font(.custom(lightFont, size: 18))
							UppercasedText("\(nextLiveStream.instructor.firstname) \(nextLiveStream.instructor.lastname)", uppercased: isAllCaps)
								.foregroundColor(Color.white)
								.font(.custom(regularFont, size: 18))
						}
						.padding(.bottom, 10)
						LiveCountDown(
							date: nextLiveStream.startDate,
							isAllCaps: isAllCaps,
							lightForegroundColor: lightForegroundColor,
							regularFont: regularFont)


					}.padding(.horizontal, 60)
					Spacer()
					Button(action: {}) {
						RemindMeButton(backgroundColor: remindMeButtonBackgroundColor,
													 isAllCapps: isAllCaps,
													 accentColor: accentColor,
													 regularFont: regularFont)
							.padding(.horizontal, 23)
					}
				}
			}
			.padding(.top, proxy?.safeAreaInsets.top ?? 0)
			.padding(.bottom, (proxy?.safeAreaInsets.bottom != nil) ? proxy!.safeAreaInsets.bottom + 20 : 0)
		}
	}
}
