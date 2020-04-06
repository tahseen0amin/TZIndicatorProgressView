import XCTest
@testable import TZIndicatorProgressView

final class TZIndicatorProgressViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let progressView = TZIndicatorProgressView(frame: CGRect(x: 0, y: 80, width: 400, height: 100))
        progressView.labels = ["Hello", "How", "Are", "YOU"]
        XCTAssertEqual(progressView.labels.count, 4)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
