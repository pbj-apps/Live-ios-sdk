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
	let fontName: String
	let onTap: () -> Void
	
	init(
		title: String,
		price: String,
		detail: String,
		image: URL?,
		fontName: String,
		onTap: @escaping () -> Void) {
			self.title = title
			self.price = price
			self.detail = detail
			self.image = image
			self.fontName = fontName
			self.onTap = onTap
		}
	
	var body: some View {
		Button(action: onTap) {
			HStack(alignment: .top) {
				VStack(alignment: .leading) {
					titleView
						.padding(.top, 11)
					priceView
						.padding(.top, 1)
					divider
						.padding(.top, -2)
					detailView
				}
				Spacer()
					.frame(width: 20)
				ZStack {
					GeometryReader { proxy in
						LiveAsyncImage(url: image?.absoluteString)
							.frame(width: proxy.size.width, height: proxy.size.height)
					}
				}
				.frame(width: 100, height: 100)
				.background(Color(red: 239.0/255, green: 239.0/255, blue: 239.0/255))
				.cornerRadius(6)
			}
			.padding(16)
			.frame(width: 310, height: 132)
			.background(Color.white)
			.cornerRadius(16)
		}.buttonStyle(PlainButtonStyle())
	}
	
	var titleView: some View {
		Text(title)
			.font(.custom(fontName, size: 16))
			.foregroundColor(.black)
	}
	
	var priceView: some View {
		Text("$\(price)")
			.font(.custom(fontName, size: 14))
			.foregroundColor(.black)
	}
	
	var detailView: some View {
		Text(detail)
			.multilineTextAlignment(.leading)
			.lineLimit(2)
			.font(.custom(fontName, size: 10))
			.foregroundColor(.black)
			.opacity(0.5)
			.fixedSize(horizontal: false, vertical: true)
	}
	
	var divider: some View {
		Rectangle()
			.foregroundColor(Color.init(red: 202/255.0, green: 202/255.0, blue: 202/255.0, opacity: 1))
			.frame(height: 1)
			.frame(maxWidth: .infinity)
	}
}


struct ProductCard_Previews: PreviewProvider {
	static var previews: some View {
		ProductCard(
			title: "Apple Airpods",
			price: "29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			fontName: "",
			onTap: {})
			.previewLayout(.sizeThatFits)
	}
}
