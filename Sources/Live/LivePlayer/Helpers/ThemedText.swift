//
//  SwiftUIView.swift
//  
//
//  Created by Sacha on 27/09/2020.
//

import SwiftUI

public struct ThemedText: View {

	@EnvironmentObject var theme: Theme
	private let text: String

	public init(_ content: String) {
		self.text = content
	}

	public var body: some View {
		Text(theme.isAllCaps ? text.uppercased() : text)
	}
}

struct ThemedText_Previews: PreviewProvider {
	static var previews: some View {
		ThemedText("Hello, World!")
			.environmentObject(Theme())
	}
}
