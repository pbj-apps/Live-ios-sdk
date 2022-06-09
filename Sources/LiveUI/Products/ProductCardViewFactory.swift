//
//  ProductCardViewFactory.swift
//  
//
//  Created by Sacha Durand Saint Omer on 09/06/2022.
//

import Foundation
import SwiftUI
import Live

public protocol ProductCardViewFactory {
	associatedtype ProductCardView: View
	func makeProductCard(product: Product) -> ProductCardView
}
