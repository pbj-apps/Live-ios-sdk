//
//  ImageView.swift
//  
//
//  Created by Sacha on 02/11/2020.
//

import SwiftUI
import FetchImage

public struct ImageView: View {

	@EnvironmentObject var theme: Theme
	@ObservedObject var image: FetchImage

	public init(image: FetchImage) {
		self.image = image
	}

	public var body: some View {
		ZStack {
			Rectangle().fill(theme.imagePlaceholderColor)
			image.view?
				.resizable()
				.aspectRatio(contentMode: .fill)
		}
		.onAppear(perform: image.fetch)
		.onDisappear(perform: image.cancel)
	}
}
