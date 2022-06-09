//
//  DefaultProductCardViewFactory.swift
//  
//
//  Created by Sacha Durand Saint Omer on 09/06/2022.
//

import Foundation
import SwiftUI
import Live

public class DefaultProductCardViewFactory: ProductCardViewFactory {
	
	public func makeProductCard(product: Product) -> some View {
		ProductComponent(product: product, fontName: "", onTap: {})
	}
	
	public init() {}
}
