import XCTest
@testable import LiveCore

final class LiveCoreTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LiveCore().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
