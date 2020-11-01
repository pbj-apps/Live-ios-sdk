//
//  ChatRepository.swift
//  
//
//  Created by Sacha on 26/07/2020.
//

import Foundation
import Combine

public protocol ChatRepository {
	func getChatMessages(for livestream: LiveStream) -> AnyPublisher<[ChatMessage], Error>
	func postChatMessage(_ user: User?, message: String, on livestream: LiveStream) -> AnyPublisher<Void, Error>
}
