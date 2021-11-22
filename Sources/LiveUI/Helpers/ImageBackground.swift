//
//  ImageBackground.swift
//  
//
//  Created by Sacha on 11/11/2020.
//

import SwiftUI


struct ImageBackground: View {
	
	let url: String?
	
	public var body: some View {
		// Somehow without the top level GeometryReader
		// The image "pushes" the content down and buttons
		// end up cropped.
		GeometryReader { proxy in
			LiveAsyncImage(url: url)
				.frame(width: proxy.size.width, height: proxy.size.height)
				.clipped()
		}
		.edgesIgnoringSafeArea(.all)
	}
}
