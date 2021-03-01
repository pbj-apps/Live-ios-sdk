//
//  SwiftUIView.swift
//  
//
//  Created by Sacha on 01/03/2021.
//

import SwiftUI

class SDKPlayerViewModel: ObservableObject {

	@Published var isLoadingLiveStream = false
}

struct SDKPlayerView: View {

	@ObservedObject var viewModel: SDKPlayerViewModel

	var body: some View {
		if viewModel.isLoadingLiveStream {
			ZStack {
				Color.black
				HStack {
					Text("Loading Livestream...")
						.foregroundColor(.white)
					ActivityIndicator(isAnimating: .constant(true), style: UIActivityIndicatorView.Style.medium, color: .white)
				}
			}.edgesIgnoringSafeArea(.all)
		} else {
			Text("Idle")
		}
	}
}

struct SDKPlayerView_Previews: PreviewProvider {
	static var previews: some View {
		SDKPlayerView(viewModel: SDKPlayerViewModel())
	}
}
