//
//  SwiftUIView.swift
//  
//
//  Created by Sacha on 01/03/2021.
//

import SwiftUI

struct SDKPlayerView: View {

	@ObservedObject var viewModel: SDKPlayerViewModel

	var body: some View {

		if let show = viewModel.show {
			ShowPreview(show: show, didTapClose: { viewModel.didTapClose() })
				.transition(.opacity)
		} else if let _ = viewModel.liveStream {
			// TODO Fade in entry
			GeometryReader { proxy in
				LivePlayer(
					viewModel: viewModel.livePlayerViewModel!,
					finishedPlaying: { print("Finished playing") },
					close: {
						viewModel.didTapClose()
					},
					proxy: proxy,
					isAllCaps: false,
					regularFont: "HelveticaNeue",
					lightFont: "Helvetica-Light",
					lightForegroundColor: .white,
					imagePlaceholderColor: Color(red: 239.0/255, green: 239.0/255, blue: 239.0/255),
					accentColor: .black,
					remindMeButtonBackgroundColor: .white,
					isChatEnabled: false,
					chatMessages: [],
					fetchMessages: {},
					sendMessage: { _ in }
				)
			}
		}
		else if viewModel.isLoading {
			ZStack {
				Color.black
				VStack {
					Text("Loading Livestream...")
						.foregroundColor(.white)
					ActivityIndicator(isAnimating: .constant(true), style: UIActivityIndicatorView.Style.medium, color: .white)
				}
			}.edgesIgnoringSafeArea(.all)
		} else if let error = viewModel.error {
			Text("Error: \(error.localizedDescription)")
		} else {
			SDKPlayerNoStreamAvailableView(didTapClose: viewModel.didTapClose)
		}
	}
}

struct SDKPlayerView_Previews: PreviewProvider {
	static var previews: some View {
		SDKPlayerView(viewModel: SDKPlayerViewModel())
	}
}


struct SDKPlayerNoStreamAvailableView: View {

	let didTapClose: () -> Void

	var body: some View {
		GeometryReader { proxy in
			ZStack {
				Color.black
				VStack {
					HStack {
						Spacer()
						Button(action: {
							withAnimation {
								didTapClose()
							}
						}) {
							Image(systemName: "xmark")
								.resizable()
								.scaledToFit()
								.foregroundColor(Color.white)
								.frame(height: 13)
						}
					}
					Spacer()
					Text("No Livestream")
						.foregroundColor(.white)
						.font(.system(size: 24))
					Text("Looks like there is no livestream available at the moment, come back later!")
						.multilineTextAlignment(.center)
						.foregroundColor(.white)
					Spacer()
				}
				.padding(.top, max(proxy.safeAreaInsets.top, 20))
				.padding(.horizontal, 20)
			}.edgesIgnoringSafeArea(.all)
		}
	}
}
