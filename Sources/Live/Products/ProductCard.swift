//
//  ProductCard.swift
//  
//
//  Created by Sacha on 07/03/2021.
//

import SwiftUI

struct ProductCard: View {
	
	let title: String
	let price: String
	let detail: String
	let image: URL?
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Spacer()
				Text(title)
					.font(.system(size: 24)) // GT Walsheim 400
					.foregroundColor(.black)
				Text(price)
					.font(.system(size: 22))
					.foregroundColor(.black)
				Divider()
					.background(Color.init(red: 202/255.0, green: 202/255.0, blue: 202/255.0, opacity: 1))
				Text(detail)
					.multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
					.font(.system(size: 16))
					.foregroundColor(.black)
					.opacity(0.5)
					.fixedSize(horizontal: false, vertical: true)
				
			}
			Spacer()
				.frame(width: 20)
			ZStack {
				Image("")
					.cornerRadius(8)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.aspectRatio(1, contentMode: .fill)
			.fixedSize(horizontal: true, vertical: false)
			.background(Color.gray)
			.cornerRadius(8)
		}
		.frame(width: 310, height: 132)
		.padding(16)
		.background(Color.white)
		.cornerRadius(16)
	}
}


struct ProductCard_Previews: PreviewProvider {
	static var previews: some View {
		ProductCard(
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil)
			.previewLayout(.sizeThatFits)
	}
}
