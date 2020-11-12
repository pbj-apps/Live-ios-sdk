//
//  SwiftUIView.swift
//  
//
//  Created by Sacha on 25/09/2020.
//

import SwiftUI

struct RemindMeButton: View {

	let backgroundColor: Color
	let isAllCapps: Bool
	let accentColor: Color
	let regularFont: String

	var body: some View {
		HStack {
			Spacer()
			UppercasedText("Remind Me", uppercased: isAllCapps)
				.accentColor(accentColor)
				.font(.custom(regularFont, size: 16))
			Image(systemName: "bell.fill")
				.resizable()
				.scaledToFit()
				.frame(height: 18)
				.padding(.leading, 10)
			Spacer()
		}
		.frame(height: 50)
		.background(backgroundColor)
		.cornerRadius(10)
	}
}

struct RemindMeButton_Previews: PreviewProvider {
	static var previews: some View {
		RemindMeButton(backgroundColor: .black, isAllCapps: true, accentColor: .red, regularFont: "Helvetica")
			.previewLayout(.sizeThatFits)
	}
}
