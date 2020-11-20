//
//  SurveyTests.swift
//
//
//  Created by Sacha on 24/08/2020.
//
import XCTest
@testable import Live

final class SurveyTests: XCTestCase {

	func testParsingSurvey() {

		let json = """
        {
            "id": "aee4a99c-23d2-4527-954d-b9cb350199cd",
            "question_type": "multiple-choice",
            "title": "What are you interested in?",
            "description": "We will help you out with appropriate content.",
            "options": [
                    {
                            "id": "874bd03d-08d6-4f43-a50e-fe51f7a28721",
                            "response_type": "select-icon",
                            "text": "Option A",
                            "icons": {
                                    "svg": "https://pbj-live-media-demo.s3.amazonaws.com/excercise.png",
                                    "pdf": null
                            }
                    },
                    {
                            "id": "b99a6e3d-1df5-4bc2-bc6d-1db1bf0a3f9e",
                            "response_type": "select-icon",
                            "text": "Option B",
                            "icons": {
                                    "svg": "https://pbj-live-media-demo.s3.amazonaws.com/excerciseB.png",
                                    "pdf": null
                            }
                    },
                    {
                            "id": "4080cb54-7b67-4802-8800-3845bfd09bfe",
                            "response_type": "select-icon",
                            "text": "Option C",
                            "icons": {
                                    "svg": "https://pbj-live-media-demo.s3.amazonaws.com/excerciseC.png",
                                    "pdf": null
                            }
                    },
                    {
                            "id": "546fc63f-8e1e-4ea7-8622-1fe337d86977",
                            "response_type": "select-icon",
                            "text": "Option D",
                            "icons": {
                                    "svg": "https://pbj-live-media-demo.s3.amazonaws.com/excerciseD.png",
                                    "pdf": null
                            }
                    }
            ],
            "order": 0,
            "is_answered": true
        }
"""
		let data = json.data(using: .utf8)!
		let decoder = JSONDecoder()
		let jsonSurvey = try? decoder.decode(JSONSurvey.self, from: data)
		let survey = jsonSurvey?.survey

		XCTAssertEqual(survey?.id, "aee4a99c-23d2-4527-954d-b9cb350199cd")
		XCTAssertEqual(survey?.title, "What are you interested in?")
		XCTAssertEqual(survey?.description, "We will help you out with appropriate content.")
		XCTAssertEqual(survey?.options.count, 4)
		XCTAssertEqual(survey?.options[0].id, "874bd03d-08d6-4f43-a50e-fe51f7a28721")
		XCTAssertEqual(survey?.options[0].title, "Option A")
		XCTAssertEqual(survey?.options[0].iconURL, URL(string: "https://pbj-live-media-demo.s3.amazonaws.com/excercise.png"))
		XCTAssertEqual(survey?.options[1].id, "b99a6e3d-1df5-4bc2-bc6d-1db1bf0a3f9e")
		XCTAssertEqual(survey?.options[1].title, "Option B")
		XCTAssertEqual(survey?.options[1].iconURL, URL(string: "https://pbj-live-media-demo.s3.amazonaws.com/excerciseB.png"))
		XCTAssertEqual(survey?.options[2].id, "4080cb54-7b67-4802-8800-3845bfd09bfe")
		XCTAssertEqual(survey?.options[2].title, "Option C")
		XCTAssertEqual(survey?.options[2].iconURL, URL(string: "https://pbj-live-media-demo.s3.amazonaws.com/excerciseC.png"))
		XCTAssertEqual(survey?.options[3].id, "546fc63f-8e1e-4ea7-8622-1fe337d86977")
		XCTAssertEqual(survey?.options[3].title, "Option D")
		XCTAssertEqual(survey?.options[3].iconURL, URL(string: "https://pbj-live-media-demo.s3.amazonaws.com/excerciseD.png"))
	}

	static var allTests = [
		("testParsingSurvey", testParsingSurvey)
	]
}
