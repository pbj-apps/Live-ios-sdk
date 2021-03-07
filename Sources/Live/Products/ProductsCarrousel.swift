//
//  ProductsCarrousel.swift
//  
//
//  Created by Sacha on 07/03/2021.
//

import SwiftUI

struct ProductsCarrousel: View {
	
	let products: [Product]
	
	var body: some View {
		ScrollView(.horizontal) {
			HStack {
				ForEach(products, id:\.title) { product in
					ProductCard(
						title: product.title,
						price: product.price,
						detail: product.detail,
						image: product.image)
				}
			}
		}
	}
}

struct ProductsCarrousel_Previews: PreviewProvider {
	static var previews: some View {
		let product1 = Product(
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			link: nil)
		let product2 = Product(
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			link: nil)
		let product3 = Product(
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			link: nil)
		ProductsCarrousel(products: [product1, product2, product3])
	}
}
