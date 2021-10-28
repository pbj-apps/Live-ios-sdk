//
//  File.swift
//  
//
//  Created by Sacha on 28/10/2021.
//

import SwiftUI
import Kingfisher

public struct LiveAsyncImage: View {
	
	let url: String?
	
	public var body: some View {
		KFImage(URL(string: url!))
			.resizable()
			.scaledToFill()
	}
}
