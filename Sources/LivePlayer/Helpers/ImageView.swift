//
//  ImageView.swift
//  
//
//  Created by Sacha on 02/11/2020.
//

import SwiftUI
import FetchImage

public struct LiveImageView: View {

	let placeholderColor: Color
	@ObservedObject var image: FetchImage

	public init(image: FetchImage, placeholderColor: Color) {
		self.image = image
		self.placeholderColor = placeholderColor
	}

	public var body: some View {
		ZStack {
			Rectangle().fill(placeholderColor)
			image.view?
				.resizable()
				.aspectRatio(contentMode: .fill)
		}
		.onAppear(perform: image.fetch)
		.onDisappear(perform: image.cancel)
	}
}
