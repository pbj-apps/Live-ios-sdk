//
//  VodPlayerView.swift
//  
//
//  Created by Sacha on 29/10/2021.
//

import SwiftUI
import AVFoundation

public struct VodPlayerView: View {
	
	let player: AVPlayer
	let showsControls: Bool
	let isPlaying: Bool
	let tapped: () -> Void
	let play: () -> Void
	let pause: () -> Void
	let stop: () -> Void
	let currentTimeLabel: String
	let endTimeLabel: String
	let sliderValue: Float
	let setSliderEditing: (Bool) -> Void
	let sliderChanged: (Float) -> Void
	let sliderDidEndEditing: () -> Void
	let close: () -> Void
	let topLeftButton: AnyView?
	
	public var body: some View {
		GeometryReader { proxy in
			ZStack {
				Color.black
				SwiftUIAVPlayer(player: player)
					.onTapGesture {
						withAnimation {
							tapped()
						}
					}
				controlsOverlay(safeAreaInsets: proxy.safeAreaInsets)
					.opacity(showsControls ? 1 : 0)
			}
			.edgesIgnoringSafeArea(.all)
		}
	}
	
	func controlsOverlay(safeAreaInsets: EdgeInsets) -> some View {
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
					sliderChanged(value)
				})
				Slider(value:sliderBinding, in: 0...1) { isEditing in
					setSliderEditing(isEditing)
					if !isEditing {
						sliderDidEndEditing()
					}
				}
				.padding()
                HStack {
                    timeLabel(text: currentTimeLabel)
                    Spacer()
                    timeLabel(text: endTimeLabel)
                }
                .padding(.horizontal)
			}
			.padding(.top, safeAreaInsets.top)
			.padding(.leading, safeAreaInsets.leading)
			.padding(.bottom, safeAreaInsets.bottom)
			.padding(.trailing, safeAreaInsets.trailing)
		}
	}
    
    func timeLabel(text: String) -> some View {
        Text(text)
            .font(Font.system(size: 12))
            .foregroundColor(.white)
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
}

struct LiveVodPlayerView_Previews: PreviewProvider {
	static var previews: some View {
		Text("LiveVodPlayerView")
	}
}
