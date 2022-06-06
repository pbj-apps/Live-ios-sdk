//
//  LivePlayerInfoHeader.swift
//  
//
//  Created by Sacha Durand Saint Omer on 06/06/2022.
//

import SwiftUI
import Live

struct LivePlayerInfoHeader: View {
	
	let title: String
	let isLive: Bool
	let regularFont: String
	let close: () -> Void
	
	var body: some View {
		ZStack {
			HStack {
				LiveIndicatorView(isLive: isLive)
				Spacer()
				closeButton
			}
			HStack {
				Spacer()
				UppercasedText(title, uppercased: false)
					.foregroundColor(Color.white)
					.font(.custom(regularFont, size: 18))
					.multilineTextAlignment(TextAlignment.center)
				Spacer()
			}.padding(.horizontal, 40)
		}
	}
	
	var closeButton: some View {
		Button(action: {
			withAnimation {
				close()
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
}


struct LivePlayerInfoHeader_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			LivePlayerInfoHeader(title: "Summer Essentials",
													 isLive: true,
													 regularFont: "",
													 close: {})
			LivePlayerInfoHeader(title: "Summer Essentials",
													 isLive: false,
													 regularFont: "",
													 close: {})
		}
		.background(Color.gray)
		.previewLayout(.sizeThatFits)
	}
}
