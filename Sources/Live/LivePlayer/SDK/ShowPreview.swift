//
//  ShowPreview.swift
//  
//
//  Created by Sacha on 02/03/2021.
//

import SwiftUI
import FetchImage

struct ShowPreview: View {

	let show: Show
	let didTapClose:() -> Void

	var body: some View {
		GeometryReader { proxy in
		ZStack {
			Color.black
			if let previewImageUrl = show.previewImageUrl, let url = URL(string: previewImageUrl) {
				ImageBackground(image: FetchImage(url: url))
					.frame(width: UIScreen.main.bounds.size.width)
			}
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
				VStack {
					HStack {
					Text(show.title)
						.foregroundColor(Color.white)
						.font(.system(size: 18))
						Spacer()
						Button(action: {
							withAnimation {
								didTapClose()
							}
						}) {
							Image(systemName: "xmark")
								.resizable()
								.scaledToFit()
								.foregroundColor(Color.white)
								.frame(height: 13)
						}
					}.padding(.top, 20)
					Spacer()
					Text(show.description)
						.lineLimit(5)
						.foregroundColor(Color.white)
						.font(.system(size: 50))
						.transition(.opacity)
						.lineSpacing(0.1)
						.padding(.bottom, max(proxy.safeAreaInsets.bottom + 20, 50))
				}
				.padding(.horizontal, 20)
				.padding(.top, max(proxy.safeAreaInsets.top, 20))
			}
		}.edgesIgnoringSafeArea(.all)
		}
	}
}
