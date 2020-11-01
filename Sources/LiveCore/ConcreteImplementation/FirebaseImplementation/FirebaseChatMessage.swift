//
//  FirebaseChatMessage.swift
//  Live
//
//  Created by Sacha on 26/07/2020.
//  Copyright © 2020 PBJApps. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import CodableFirebase

struct FirebaseChatMessage: Equatable, Codable {
	let text: String
	let username: String
	let date: Timestamp
}

extension Timestamp: TimestampType {}

extension FirebaseChatMessage {
	func toChatMessage() -> ChatMessage {
		return ChatMessage(text: text, username: username)
	}
}
