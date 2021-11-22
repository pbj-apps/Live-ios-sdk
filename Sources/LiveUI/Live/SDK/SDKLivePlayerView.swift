//
//  SDKLivePlayerView.swift
//  
//
//  Created by Sacha on 01/03/2021.
//

import SwiftUI
import Networking
import Live

public struct SDKLivePlayerView: View {

	@StateObject private var viewModel: SDKPlayerViewModel
	private var didTapClose: () -> Void
	let defaultsToAspectRatioFit: Bool
	
	public init(showId: String? = nil,
			 didTapClose: @escaping () -> Void,
			 defaultsToAspectRatioFit: Bool = true
	) {
		_viewModel = StateObject(wrappedValue: SDKPlayerViewModel(showId: showId))
		self.didTapClose = didTapClose
		self.defaultsToAspectRatioFit = defaultsToAspectRatioFit
	}

	public var body: some View {
		switch viewModel.state {
		case .loading:
			ZStack {
				Color.black
				VStack {
					Text("Loading Livestream...")
						.foregroundColor(.white)
					ActivityIndicator(isAnimating: .constant(true), style: UIActivityIndicatorView.Style.medium, color: .white)
				}
			}.edgesIgnoringSafeArea(.all)
		case .noLiveStream:
			SDKPlayerNoStreamAvailableView(didTapClose: didTapClose)
		case .liveStream(_):
			GeometryReader { proxy in
				LivePlayer(
					liveStream: viewModel.liveStream!,
					productRepository: Live.shared.api,
					close: didTapClose,
					proxy: proxy,
					isAllCaps: false,
					regularFont: "HelveticaNeue",
					lightFont: "Helvetica-Light",
					lightForegroundColor: .white,
					imagePlaceholderColor: Color(red: 239.0/255, green: 239.0/255, blue: 239.0/255),
					accentColor: .black,
					remindMeButtonBackgroundColor: .white,
					defaultsToAspectRatioFit: defaultsToAspectRatioFit,
					isChatEnabled: false,
					chatMessages: [],
					fetchMessages: {},
					sendMessage: { _, _ in },
					isInGuestMode: false
				)
			}
		case .show(let show):
			ShowPreview(show: show, didTapClose: didTapClose)
				.transition(.opacity)
		case .error(let error):
			SDKPlayerErrorView(error: error, didTapClose: didTapClose)
		}
	}
}

struct SDKPlayerView_Previews: PreviewProvider {
	static var previews: some View {
		SDKLivePlayerView(didTapClose: {})
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

struct SDKPlayerErrorView: View {

	let error: Error
	let didTapClose: () -> Void

	var body: some View {

		var text = error.localizedDescription

		if let netError = error as? NetworkingError {
			text = "\(netError.code.description)"
			text += "\n\(netError.jsonPayload ?? "")"
		}

		return GeometryReader { proxy in
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
					Text("Error")
						.foregroundColor(.white)
						.font(.system(size: 24))
					Text(text)
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
