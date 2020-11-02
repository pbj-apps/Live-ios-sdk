//
//  FirebaseChatRepository.swift
//  Live
//
//  Created by Sacha on 26/07/2020.
//  Copyright © 2020 PBJApps. All rights reserved.
//

import Foundation
import Combine
import Firebase

public final class FirebaseChatRepository: ChatRepository {

	public init() {}
	
	private var listeners = [ListenerRegistration]()
	
	public func getChatMessages(for livestream: LiveStream) -> AnyPublisher<[ChatMessage], Error> {
		let publisher = PassthroughSubject<[FirebaseChatMessage], APIError>()
		let listener = FirestoreClient.shared.getDb()
			.collection("chat")
			.document(livestream.id)
			.collection("messages")
			.order(by: "date", descending: true)
			.addSnapshotListener { snapshot, error in
				guard let documents = snapshot?.documents else {
					if let error = error as? APIError {
						publisher.send(completion: Subscribers.Completion<APIError>.failure(error))
					} else {
						publisher.send(completion: Subscribers
														.Completion<APIError>
														.failure(APIError.genericError(description: "Error while decoding messages.")))
					}
					return
				}
				do {
					let messages: [FirebaseChatMessage] = try documents.map {
						do {
							return try $0.toObject()
						} catch let error {
							throw error
						}
					}
					publisher.send(messages)
				} catch {
					if let error = error as? APIError {
						publisher.send(completion: Subscribers.Completion<APIError>.failure(error))
					} else {
						publisher.send(completion: Subscribers
														.Completion<APIError>
														.failure(APIError.genericError(description: "Error while decoding messages.")))
					}
				}
			}
		self.listeners.append(listener)
		
		return publisher
			.map { firebaseChatMessages -> [ChatMessage] in
				return firebaseChatMessages.map { $0.toChatMessage() }
			}
			.mapError { $0 as Error}
			.receive(on: OperationQueue.main)
			.eraseToAnyPublisher()
	}
	
	public func postChatMessage(_ user: User?, message: String, on livestream: LiveStream) -> AnyPublisher<Void, Error> {
		if let user = user,
			 let request = try? FirebaseChatMessage(text: message,
																							username: user.firstname,
																							date: Timestamp(date: Date())).toFirebaseData() {
			FirestoreClient.shared.getDb()
				.collection("chat")
				.document(livestream.id)
				.collection("messages")
				.addDocument(data: request)
		}
		return Just(())
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}
}
