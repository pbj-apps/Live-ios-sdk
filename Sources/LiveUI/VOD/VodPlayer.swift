//
//  VodPlayer.swift
//  
//
//  Created by Sacha on 29/10/2021.
//

import SwiftUI
import AVFoundation

public struct VodPlayer: View {
	
	@StateObject private var viewModel: VodPlayerViewModel
	
	private let topLeftButton: AnyView?
	private let close: () -> Void
	
	public init(url: URL, close: @escaping () -> Void, topLeftButton: AnyView? = nil) {
		self._viewModel = StateObject(wrappedValue: VodPlayerViewModel(url: url))
		self.close = close
		self.topLeftButton = topLeftButton
	}
	
	public var body: some View {
		VodPlayerView(
			player: viewModel.player,
			showsControls: viewModel.showsControls,
			isPlaying: viewModel.isPlaying,
			tapped: viewModel.tapped,
			play: viewModel.play,
			pause: viewModel.pause,
			stop: viewModel.stop,
			currentTimeLabel: viewModel.currentTimeLabel,
			endTimeLabel: viewModel.endTimeLabel,
			sliderValue: viewModel.sliderValue,
			setSliderEditing: viewModel.setSliderEditing,
			sliderChanged: viewModel.sliderChanged,
			sliderDidEndEditing: viewModel.endEditingSlider,
			close: close,
			topLeftButton: topLeftButton)
	}
}


