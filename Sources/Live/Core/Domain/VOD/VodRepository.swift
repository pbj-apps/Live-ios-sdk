//
//  VodRepository.swift
//  
//
//  Created by Sacha on 24/07/2020.
//

import Foundation
import Combine

public protocol VodRepository {
	func getVodCategories() -> AnyPaginator<VodCategory>
	func getPlaylist(playlist: VodPlaylist) -> AnyPublisher<VodPlaylist, Error>
}
