//
//  LiveCountDown.swift
//  
//
//  Created by Sacha on 04/09/2020.
//

import SwiftUI

struct LiveCountDown: View {
	
	@EnvironmentObject var theme: Theme
	let date: Date
	@State var liveIn = "..."
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	
	var body: some View {
		ThemedText(liveIn)
			.foregroundColor(theme.lightForegroundColor)
			.font(.custom(theme.fonts.regular, size: 45))
			.onAppear {
				liveIn = countdown()
			}
			.onReceive(timer) { _ in
				liveIn = countdown()
			}
	}
	
	func countdown() -> String {
		if date < Date() {
			return ""
		}
		let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: date)
		if let hours = diffComponents.hour, let minutes = diffComponents.minute, let seconds = diffComponents.second {
			return "\(String(format: "%02d", hours)) \(String(format: "%02d", minutes)) \(String(format: "%02d", seconds))"
		}
		return "..."
	}
}

struct LiveCountDown_Previews: PreviewProvider {
	static var previews: some View {
		LiveCountDown(date: Date().addingTimeInterval(1000), liveIn: "Test")
			.background(Color.black)
			.previewLayout(PreviewLayout.fixed(width: 300, height: 100))
	}
}
