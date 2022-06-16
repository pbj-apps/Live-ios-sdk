//
//  VodPlayerOverlay.swift
//  
//
//  Created by Sacha Durand Saint Omer on 16/06/2022.
//

import SwiftUI

struct VodPlayerOverlay: View {
	
	let isPlaying: Bool
	let tapped: () -> Void
	let play: () -> Void
	let pause: () -> Void
	let stop: () -> Void
	let currentTimeSeconds: Double
	let durationSeconds: Double
	let sliderValue: Float
	let seekToProgress: (Float) -> Void
	let endSeek: () -> Void
	let close: () -> Void
	let safeAreaInsets: EdgeInsets
	let topLeftButton: AnyView?
	
	var body: some View {
		ZStack {
			Color.black.opacity(0.5)
				.onTapGesture {
					withAnimation {
						tapped()
					}
				}
			VStack {
				HStack {
					if let topLeftButton = topLeftButton {
						topLeftButton
					}
					Spacer()
					closeButton
				}
				Spacer()
				HStack {
					Spacer()
					playPauseButton
					Spacer()
				}
				Spacer()
				let sliderBinding: Binding<Float> = Binding(get: {
					sliderValue
				}, set: { value in
					seekToProgress(value)
				})
				Slider(value:sliderBinding, in: 0...1) { isEditing in
					if !isEditing {
						endSeek()
					}
				}
				.padding()
				HStack {
					timeLabel(text: formattedTime(seconds: currentTimeSeconds))
					Spacer()
					timeLabel(text: formattedTime(seconds: durationSeconds))
				}
				.padding(.horizontal)
			}
			.padding(.top, safeAreaInsets.top)
			.padding(.leading, safeAreaInsets.leading)
			.padding(.bottom, safeAreaInsets.bottom)
			.padding(.trailing, safeAreaInsets.trailing)
		}
	}
	
	var closeButton: some View {
		Button(action: {
			withAnimation {
				stop()
				close()
			}
		}) {
			Image(systemName: "xmark")
				.resizable()
				.foregroundColor(.white)
				.frame(width: 20, height: 20)
				.padding()
		}
	}
	
	var playPauseButton: some View {
		Button(action: {
			withAnimation {
				if isPlaying {
					pause()
				} else {
					play()
				}
			}
		}) {
			Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
				.resizable()
				.foregroundColor(.white)
				.frame(width: 70, height: 70)
		}
	}
	
	func timeLabel(text: String) -> some View {
		Text(text)
			.font(Font.system(size: 12))
			.foregroundColor(.white)
	}
	
	func formattedTime(seconds: Double) -> String {
		let timeInterval: TimeInterval = TimeInterval(seconds)
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [.hour, .minute, .second]
		formatter.zeroFormattingBehavior = [.pad]
		let formattedString = formatter.string(from: timeInterval) ?? "0:00"
		if formattedString.starts(with: "00:") {
			return String(formattedString.dropFirst(3))
		}
		return formattedString
	}
}

struct VodPlayerOverlay_Previews: PreviewProvider {
	static var previews: some View {
		VodPlayerOverlay(
			isPlaying: true,
			tapped: {},
			play: {},
			pause: {},
			stop: {},
			currentTimeSeconds: 120,
			durationSeconds: 1000,
			sliderValue: 0.1,
			seekToProgress: { _ in },
			endSeek: { },
			close: {},
			safeAreaInsets: EdgeInsets(),
			topLeftButton: nil)
	}
}
