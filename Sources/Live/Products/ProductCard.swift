//
//  ProductCard.swift
//  
//
//  Created by Sacha on 07/03/2021.
//

import SwiftUI
import FetchImage

struct ProductCard: View {

	let title: String
	let price: String
	let detail: String
	let image: URL?
	let fontName: String
	let onClick: () -> Void
	@ObservedObject var imageView: FetchImage

	init(
		title: String,
	price: String,
	detail: String,
	image: URL?,
	fontName: String,
		onClick: @escaping () -> Void) {
		self.title = title
		self.price = price
		self.detail = detail
		self.image = image
		self.fontName = fontName
		self.onClick = onClick
		if let image = image {
			imageView = FetchImage(url: image)
		} else {
			imageView = FetchImage(url: URL(string: "http://")!)
		}
	}
	
	var body: some View {
		Button(action: onClick) {
			HStack {
				VStack(alignment: .leading) {
					Spacer()
					Text(title)
						.font(.custom(fontName, size: 16)) // GT Walsheim 400
						.foregroundColor(.black)
					Text("$\(price)")
						.font(.custom(fontName, size: 14))
						.foregroundColor(.black)
					Divider()
						.background(Color.init(red: 202/255.0, green: 202/255.0, blue: 202/255.0, opacity: 1))
					Text(detail)
						.multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
						.font(.custom(fontName, size: 10))
						.foregroundColor(.black)
						.opacity(0.5)
						.fixedSize(horizontal: false, vertical: true)

				}
				Spacer()
					.frame(width: 20)
				ZStack {
					GeometryReader { proxy in
					imageView
							.view?
							.resizable()
							.aspectRatio(contentMode: .fill)
							.frame(width: proxy.size.width, height: proxy.size.height)
					}
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.aspectRatio(1, contentMode: .fill)
				.fixedSize(horizontal: true, vertical: false)
				.background(Color.gray)
				.cornerRadius(8)
			}
			.padding(16)
			.frame(width: 310, height: 132)
			.background(Color.white)
			.cornerRadius(16)
		}.buttonStyle(PlainButtonStyle())
	}
}


struct ProductCard_Previews: PreviewProvider {
	static var previews: some View {
		ProductCard(
			title: "Apple Airpods",
			price: "$29.99",
			detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`",
			image: nil,
			fontName: "",
			onClick: {})
			.previewLayout(.sizeThatFits)
	}
}
