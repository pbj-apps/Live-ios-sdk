//
//  SwiftUIView.swift
//  
//
//  Created by Sacha on 27/09/2020.
//

import SwiftUI

public struct UppercasedText: View {

	let uppercased: Bool
	private let text: String

	public init(_ content: String, uppercased: Bool) {
		self.text = content
		self.uppercased = uppercased
	}

	public var body: some View {
		Text(uppercased ? text.uppercased() : text)
	}
}

struct ThemedText_Previews: PreviewProvider {
	static var previews: some View {
		UppercasedText("Hello, World!", uppercased: true)
	}
}
