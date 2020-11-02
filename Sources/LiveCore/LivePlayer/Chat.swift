//
//  SwiftUIView.swift
//  
//
//  Created by Thibault Gauche on 13/10/2020.
//

import SwiftUI
import Combine

struct Chat: View {
	@EnvironmentObject var liveStore: LiveStore
	@EnvironmentObject var theme: Theme

	var body: some View {
		ScrollView(.vertical, showsIndicators: false) {
			VStack(alignment: .leading) {
				ForEach(liveStore.chatMessages) { message in
					HStack(alignment: .center, spacing: 5) {
						Text(message.username)
							.foregroundColor(.white)
							.font(.custom(theme.fonts.regular, size: 14))
						Text(message.text)
							.foregroundColor(.white)
							.font(.custom(theme.fonts.light, size: 14))
						Spacer()
					}
					.flippedUpsideDown()
				}
			}
		}
		.flippedUpsideDown()
		.frame(maxHeight: 200, alignment: .bottomTrailing)
		.clipped()
	}
}

struct Chat_Previews: PreviewProvider {
	static var previews: some View {
		Chat()
	}
}
