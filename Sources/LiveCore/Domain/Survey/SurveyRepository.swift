//
//  SurveyRepository.swift
//  
//
//  Created by Sacha on 24/08/2020.
//

import Foundation
import Combine

public protocol SurveyRepository {
	func fetchSurvey() -> AnyPublisher<Survey, Error>
	func answerSurvey(survey: Survey, with options: [SurveyOption]) -> AnyPublisher<(), Error>
	func markSurveyAsAnswered() -> AnyPublisher<(), Error>
}
