//
//  ChatMessage.swift
//  
//
//  Created by Sacha on 26/07/2020.
//

import Foundation

public struct ChatMessage: Identifiable, Hashable {
	public let id = UUID()
	public let text: String
	public let username: String

	public init(text: String, username: String) {
		self.text = text
		self.username = username
	}
}
