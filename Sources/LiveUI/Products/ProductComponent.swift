//
//  ProductComponent.swift
//  
//
//  Created by Sacha on 07/03/2021.
//

import SwiftUI
import Live

struct ProductComponent: View {
	
	let product: Product
	let fontName: String
	let onTap: () -> Void
	
	var body: some View {
		ProductCard(
			title: product.title,
			price: product.price,
			detail: product.detail,
			image: product.image,
			fontName: fontName,
			onTap: onTap)
	}
}

struct ProductComponent_Previews: PreviewProvider {
	static var previews: some View {
		let product = Product(
            id: "123",
            externalId: "456",
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			link: nil,
			isHighlighted: false,
			highlightTimings: nil)
		ProductComponent(product: product, fontName: "", onTap: {})
			.previewLayout(.sizeThatFits)
	}
}
