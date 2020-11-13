//
//  SwiftUIView.swift
//  
//
//  Created by Thibault Gauche on 13/10/2020.
//

import SwiftUI
import Combine

struct Chat: View {

	let chatMessages: [ChatMessage]
	let regularFont: String
	let lightFont: String

	var body: some View {
		ScrollView(.vertical, showsIndicators: false) {
			VStack(alignment: .leading) {
				ForEach(chatMessages) { message in
					HStack(alignment: .center, spacing: 5) {
						Text(message.username)
							.foregroundColor(.white)
							.font(.custom(regularFont, size: 14))
						Text(message.text)
							.foregroundColor(.white)
							.font(.custom(lightFont, size: 14))
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
		Chat(
			chatMessages: [],
			regularFont: "HelveticaNeue",
			lightFont: "Helvetica-Light")
	}
}
