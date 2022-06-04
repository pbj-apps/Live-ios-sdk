//
//  RestApi+ Survey.swift
//  
//
//  Created by Sacha on 24/08/2020.
//

import Foundation
import Combine
import Networking

extension RestApi: SurveyRepository {
	public func fetchSurvey() -> AnyPublisher<Survey, Error> {
		get("/survey/questions").tryMap { (page: JSONSurveyPage) -> Survey in
			guard let survey = page.jsonSurvey?.survey else {
				throw ParsingError.default
			}
			return survey
		}.eraseToAnyPublisher()
	}

	public func answerSurvey(survey: Survey, with options: [SurveyOption]) -> AnyPublisher<Void, Error> {
		post("/survey/questions/\(survey.id)/answer", params: ["options": options.map { $0.id }])
	}

	public func markSurveyAsAnswered() -> AnyPublisher<Void, Error> {
		post("/me/survey-attempted")
	}
}

enum ParsingError: Error {
	case `default`
}
