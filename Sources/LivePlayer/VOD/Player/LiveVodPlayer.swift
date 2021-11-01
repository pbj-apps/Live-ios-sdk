//
//  LiveVodPlayer.swift
//  
//
//  Created by Sacha on 29/10/2021.
//

import SwiftUI
import AVFoundation

public struct LiveVodPlayer: View {
	
	@StateObject private var viewModel: LiveVodPlayerViewModel
	
	private let topLeftButton: AnyView?
	private let close: () -> Void
	
	public init(url: URL, close: @escaping () -> Void, topLeftButton: AnyView? = nil) {
		self._viewModel = StateObject(wrappedValue: LiveVodPlayerViewModel(url: url))
		self.close = close
		self.topLeftButton = topLeftButton
	}
	
	public var body: some View {
		LiveVodPlayerView(player: viewModel.player,
											showsControls: viewModel.showsControls,
											isPlaying: viewModel.isPlaying,
											tapped: viewModel.tapped,
											play: viewModel.play,
											pause: viewModel.pause,
											stop: viewModel.stop,
											sliderValue: viewModel.sliderValue,
											setSliderEditing: viewModel.setSliderEditing,
											sliderChanged: viewModel.sliderChanged,
											sliderDidEndEditing: viewModel.endEditingSlider,
											close: close,
											topLeftButton: topLeftButton)
	}
}


