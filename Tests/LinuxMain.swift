import XCTest

import LiveCoreTests

var tests = [XCTestCaseEntry]()
tests += UserTests.allTests()
tests += SurveyTests.allTests()
XCTMain(tests)
