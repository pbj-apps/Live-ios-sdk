//
//  ProductRepository.swift
//  
//
//  Created by Sacha on 03/03/2021.
//

import Foundation
import Combine

public protocol ProductRepository {
	func fetchProducts(for episode: LiveStream) -> AnyPublisher<[Product], Error>
}
