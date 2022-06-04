//
//  JSONSurvey.swift
//  
//
//  Created by Sacha on 24/08/2020.
//

import Foundation

struct JSONSurveyPage: Decodable {

	let jsonSurvey: JSONSurvey?

	enum CodingKeys: String, CodingKey {
		case results
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		let surveys = try values.decode([JSONSurvey].self, forKey: .results)
		jsonSurvey = surveys.first
	}
}

struct JSONSurvey: Decodable {

	let survey: Survey

	enum CodingKeys: String, CodingKey {
		case id
		case title
		case description
		case options
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		let options = try values.decode([JSONSurveyOption].self, forKey: .options)
		survey = Survey(id: try values.decode(String.self, forKey: .id),
										title: try values.decode(String.self, forKey: .title),
										description: try values.decode(String.self, forKey: .description),
										options: options.map { $0.surveyOption })
	}
}

struct JSONSurveyOption: Decodable {

	let surveyOption: SurveyOption

	enum CodingKeys: String, CodingKey {
		case id
		case text
		case icons
	}

	enum IconsKeys: String, CodingKey {
		case svg
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		let id = try values.decode(String.self, forKey: .id)
		let title = try values.decode(String.self, forKey: .text)
		let iconsValues = try values.nestedContainer(keyedBy: IconsKeys.self, forKey: .icons)
		var iconURL: URL?
		if let iconURLString = try? iconsValues.decode(String.self, forKey: .svg) {
			iconURL = URL(string: iconURLString)
		}
		surveyOption = SurveyOption(id: id, title: title, iconURL: iconURL)
	}
}
