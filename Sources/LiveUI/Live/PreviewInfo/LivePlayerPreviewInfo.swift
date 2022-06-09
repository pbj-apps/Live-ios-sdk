//
//  LivePlayerPreviewInfo.swift
//  
//
//  Created by Sacha Durand Saint Omer on 09/06/2022.
//

import SwiftUI

struct LivePlayerPreviewInfo: View {
	
	let message: String
	let startDate: Date
	let isAllCaps: Bool
	let regularFont: String
	let lightForegroundColor: Color
	
	var body: some View {
		VStack(alignment: .leading) {
			UppercasedText(message, uppercased: isAllCaps)
				.foregroundColor(Color.white)
				.font(.custom(regularFont, size: 50))
				.minimumScaleFactor(0.4)
				.lineSpacing(0.1)
				.fixedSize(horizontal: false, vertical: true)
				.padding(.bottom, 55)
			UppercasedText("Live in", uppercased: isAllCaps)
				.foregroundColor(Color.white)
				.font(.custom(regularFont, size: 14))
			LiveCountDown(
				date: startDate,
				isAllCaps: isAllCaps,
				lightForegroundColor: lightForegroundColor,
				regularFont: regularFont)
			.padding(.bottom, 50)
		}
	}
}

struct LivePlayerPreviewInfo_Previews: PreviewProvider {
	static var previews: some View {
		LivePlayerPreviewInfo(message: "This is a very long message d",
													startDate: Date().addingTimeInterval(1000),
													isAllCaps: false,
													regularFont: "",
													lightForegroundColor: Color.white)
		.background(Color.black)
	}
}
