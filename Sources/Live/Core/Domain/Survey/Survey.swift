//
//  Survey.swift
//  
//
//  Created by Sacha on 24/08/2020.
//

import Foundation

public struct Survey {
	let id: String
	public let title: String
	public let description: String
	public let options: [SurveyOption]

	public init(id: String, title: String, description: String, options: [SurveyOption]) {
		self.id = id
		self.title = title
		self.description = description
		self.options = options
	}
}

public struct SurveyOption: Equatable {
	public let id: String
	public let title: String
	public let iconURL: URL?
	
	public init(id: String, title: String, iconURL: URL?) {
		self.id = id
		self.title = title
		self.iconURL = iconURL
	}
}
