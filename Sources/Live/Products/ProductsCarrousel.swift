//
//  ProductsCarrousel.swift
//  
//
//  Created by Sacha on 07/03/2021.
//

import SwiftUI

struct ProductsCarrousel: View {
	
	let products: [Product]
	let fontName: String
	let leadingSpace: CGFloat
	let onTapProduct: (Product) -> Void
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 10) {
				ForEach(products, id:\.title) { product in
					ProductComponent(product: product, fontName: fontName, onTap: {
						onTapProduct(product)
					}).padding(.leading, product == products.first ? leadingSpace : 0)
				}
			}
		}
	}
}

struct ProductsCarrousel_Previews: PreviewProvider {
	static var previews: some View {
		let product1 = Product(
			id: "123",
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			link: nil)
		let product2 = Product(
			id: "123",
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			link: nil)
		let product3 = Product(
			id: "123",
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			link: nil)
		ProductsCarrousel(products: [product1, product2, product3], fontName: "", leadingSpace: 10, onTapProduct: { _ in })
	}
}
