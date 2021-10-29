//
//  LiveVodPlayer.swift
//  
//
//  Created by Sacha on 29/10/2021.
//

import SwiftUI
import Live
import Kingfisher


public struct LiveVodPlayer: View {

	let topLeftButton: AnyView?
	let close: () -> Void

	@StateObject private var viewModel: LiveVodPlayerViewModel

	public init(url: URL, close: @escaping () -> Void, topLeftButton: AnyView? = nil) {
		self._viewModel = StateObject(wrappedValue: LiveVodPlayerViewModel(url: url))
		self.close = close
		self.topLeftButton = topLeftButton
	}

	public var body: some View {
		GeometryReader { proxy in
			ZStack {
				Color.black
				VODVideoPlayer(player: viewModel.player)
					.onTapGesture {
						withAnimation {
							viewModel.tapped()
						}
					}
				controlsOverlay(safeAreaInsets: proxy.safeAreaInsets)
					.opacity(viewModel.showsControls ? 1 : 0)
			}
			.edgesIgnoringSafeArea(.all)
		}
	}

	func controlsOverlay(safeAreaInsets: EdgeInsets) -> some View {
		ZStack {
			Color.black.opacity(0.5)
				.onTapGesture {
					withAnimation {
						viewModel.tapped()
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
					viewModel.sliderValue
				}, set: { value in
					viewModel.sliderChanged(value: value)
				})
				Slider(value:sliderBinding, in: 0...1) { isEditing in
					viewModel.isEditingSlider = isEditing
					if !isEditing {
						viewModel.endEditingSlider()
					}
					print(isEditing)
				}
				.padding()
			}
			.padding(.top, safeAreaInsets.top)
			.padding(.leading, safeAreaInsets.leading)
			.padding(.bottom, safeAreaInsets.bottom)
			.padding(.trailing, safeAreaInsets.trailing)
		}
	}

	var playPauseButton: some View {
		Button(action: {
			withAnimation {
				if viewModel.isPlaying {
					viewModel.pause()
				} else {
					viewModel.play()
				}
			}
		}) {
			Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
				.resizable()
				.foregroundColor(.white)
				.frame(width: 70, height: 70)
		}
	}

	var closeButton: some View {
		Button(action: {
			withAnimation {
				viewModel.stop()
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
