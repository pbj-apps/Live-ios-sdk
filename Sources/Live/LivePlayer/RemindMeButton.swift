//
//  SwiftUIView.swift
//  
//
//  Created by Sacha on 25/09/2020.
//

import SwiftUI

struct RemindMeButton: View {

	@EnvironmentObject var theme: Theme

	var body: some View {
		HStack {
			Spacer()
			ThemedText("Remind Me")
				.accentColor(theme.accentColor)
				.font(.custom(theme.fonts.regular, size: 16))
			Image(systemName: "bell.fill")
				.resizable()
				.scaledToFit()
				.frame(height: 18)
				.padding(.leading, 10)
			Spacer()
		}
		.frame(height: 50)
		.background(theme.backgroundColor)
		.cornerRadius(10)
	}
}

struct RemindMeButton_Previews: PreviewProvider {
	static var previews: some View {
		RemindMeButton()
			.environmentObject(Theme())
			.previewLayout(.sizeThatFits)
	}
}
