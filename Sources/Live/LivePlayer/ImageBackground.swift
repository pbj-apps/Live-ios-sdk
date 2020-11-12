//
//  ImageBackground.swift
//  
//
//  Created by Sacha on 11/11/2020.
//

import SwiftUI
import FetchImage

public struct ImageBackground: View {

	@ObservedObject var image: FetchImage

	public var body: some View {
		ZStack {
			image.view?
				.resizable()
				.aspectRatio(contentMode: .fill)
		}
		.onAppear(perform: image.fetch)
		.onDisappear(perform: image.cancel)
	}
}
