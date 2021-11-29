//
//  ChatRepository.swift
//  
//
//  Created by Sacha on 26/07/2020.
//

import Foundation
import Combine

public protocol ChatRepository {
	func getChatMessages(for episode: Episode) -> AnyPublisher<[ChatMessage], Error>
	func postChatMessage(message: String, as username: String, on episode: Episode) -> AnyPublisher<Void, Error>
}
