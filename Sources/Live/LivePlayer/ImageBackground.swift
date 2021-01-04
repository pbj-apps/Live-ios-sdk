//
//  ImageBackground.swift
//  
//
//  Created by Sacha on 11/11/2020.
//

import SwiftUI
import FetchImage

struct ImageBackground: View {
	
	@ObservedObject var image: FetchImage
	
	public var body: some View {
		// Somehow without the top level GeometryReader
		// The image "pushes" the content down and buttons
		// end up cropped.
		GeometryReader { proxy in
			image.view?
				.resizable()
				.scaledToFill()
				.frame(width: proxy.size.width, height: proxy.size.height)
				.clipped()
		}
		.edgesIgnoringSafeArea(.all)
		.onAppear(perform: image.fetch)
		.onDisappear(perform: image.cancel)
	}
}
