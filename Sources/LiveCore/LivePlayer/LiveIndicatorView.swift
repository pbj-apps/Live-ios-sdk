//
//  SwiftUIView.swift
//  
//
//  Created by Sacha on 25/09/2020.
//

import SwiftUI

public struct LiveIndicatorView: View {
	let isLive: Bool
	
	public init(isLive: Bool) {
		self.isLive = isLive
	}

	public var body: some View {
		Image(isLive ? "LiveStreaming" : "UpNext", bundle: .module)
	}
}

struct LiveIndicatorView_Previews: PreviewProvider {
	static var previews: some View {
		LiveIndicatorView(isLive: true)
			.previewLayout(.sizeThatFits)
		LiveIndicatorView(isLive: true)
			.previewLayout(.sizeThatFits)
			.colorScheme(.dark)
		LiveIndicatorView(isLive: false)
			.previewLayout(.sizeThatFits)
		LiveIndicatorView(isLive: false)
			.previewLayout(.sizeThatFits)
			.colorScheme(.dark)
	}
}
