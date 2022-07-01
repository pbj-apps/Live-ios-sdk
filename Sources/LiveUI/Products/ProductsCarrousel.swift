//
//  ProductsCarrousel.swift
//  
//
//  Created by Sacha on 07/03/2021.
//

import SwiftUI
import Live

public struct ProductsCarrousel<PVF: ProductCardViewFactory>: View {
	
	let products: [Product]
	let fontName: String
	let leadingSpace: CGFloat
	let onTapProduct: (Product) -> Void
	let productCardViewViewFactory: PVF
	
	public init(
		products: [Product],
		fontName: String,
		leadingSpace: CGFloat,
		onTapProduct: @escaping (Product) -> Void,
		productCardViewViewFactory: PVF
	) {
		self.products = products
		self.fontName = fontName
		self.leadingSpace = leadingSpace
		self.onTapProduct = onTapProduct
		self.productCardViewViewFactory = productCardViewViewFactory
	}
	
	public var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 10) {
				ForEach(products, id:\.title) { product in
					productCardViewViewFactory.makeProductCard(product: product)
					.padding(.leading, product == products.first ? leadingSpace : 0)
				}
			}
		}
	}
}

struct ProductsCarrousel_Previews: PreviewProvider {
	static var previews: some View {
		let product1 = Product(
            id: "123",
            externalId: "456",
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			link: nil,
			isHighlighted: false,
			highlightTimings: nil)
		let product2 = Product(
			id: "123",
            externalId: "456",
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			link: nil,
			isHighlighted: false,
			highlightTimings: nil)
		let product3 = Product(
			id: "123",
            externalId: "456",
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			link: nil,
			isHighlighted: false,
			highlightTimings: nil)
		ProductsCarrousel(products: [product1, product2, product3], fontName: "", leadingSpace: 10, onTapProduct: { _ in }, productCardViewViewFactory: DefaultProductCardViewFactory())
	}
}
