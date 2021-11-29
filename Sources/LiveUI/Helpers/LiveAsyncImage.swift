//
//  LiveAsyncImage.swift
//  
//
//  Created by Sacha on 28/10/2021.
//

import SwiftUI
import Kingfisher

public struct LiveAsyncImage: View {
	
	let url: String?

	public init(url: String?) {
		self.url = url
	}
	
	public var body: some View {
		if let url = url {
			KFImage(URL(string: url))
				.fade(duration: 0.25)
				.resizable()
				.scaledToFill()
		}
	}
}
