//
//  ProductComponent.swift
//  
//
//  Created by Sacha on 07/03/2021.
//

import SwiftUI

struct ProductComponent: View {
	
	let product: Product
	let fontName: String
	let onClick: () -> Void
	
	var body: some View {
		ProductCard(
			title: product.title,
			price: product.price,
			detail: product.detail,
			image: product.image,
			fontName: fontName,
			onClick: onClick)
	}
}

struct ProductComponent_Previews: PreviewProvider {
	static var previews: some View {
		let product = Product(
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			link: nil)
		ProductComponent(product: product, fontName: "", onClick: {})
			.previewLayout(.sizeThatFits)
	}
}
