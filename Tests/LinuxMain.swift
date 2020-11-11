import XCTest

import LiveTests

var tests = [XCTestCaseEntry]()
tests += UserTests.allTests()
tests += SurveyTests.allTests()
XCTMain(tests)
