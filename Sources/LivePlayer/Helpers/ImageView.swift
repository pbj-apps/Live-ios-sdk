//
//  ImageView.swift
//  
//
//  Created by Sacha on 02/11/2020.
//

import SwiftUI

public struct LiveImageView: View {
	
	let placeholderColor: Color
	let url: String?
	
	public init(url: String?, placeholderColor: Color) {
		self.url = url
		self.placeholderColor = placeholderColor
	}
	
	public var body: some View {
		ZStack {
			Rectangle().fill(placeholderColor)
			LiveAsyncImage(url: url)
		}
	}
}
