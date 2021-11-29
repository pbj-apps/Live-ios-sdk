//
//  ActivityIndicator.swift
//  
//
//  Created by Sacha on 17/08/2020.
//

import SwiftUI
import UIKit

public struct ActivityIndicator: UIViewRepresentable {

	@Binding var isAnimating: Bool
	let style: UIActivityIndicatorView.Style
	let color: UIColor?

	public init(isAnimating: Binding<Bool> = .constant(true), style: UIActivityIndicatorView.Style = .medium, color: UIColor?) {
		self._isAnimating = isAnimating
		self.style = style
		self.color = color
	}

	public func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
		let view = UIActivityIndicatorView(style: style)
		if let color = color {
			view.color = color
		}
		return view
	}

	public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
		isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
	}
}

struct ActivityIndicator_Previews: PreviewProvider {
	static var previews: some View {
		ActivityIndicator(isAnimating: .constant(true), style: .medium, color: nil)
			.previewLayout(PreviewLayout.sizeThatFits)
	}
}
