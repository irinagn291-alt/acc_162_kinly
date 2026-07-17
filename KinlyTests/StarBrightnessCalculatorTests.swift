import XCTest
@testable import Kinly

final class StarBrightnessCalculatorTests: XCTestCase {
    private let calculator = StarBrightnessCalculator()

    func testNilLastInteractionReturnsMinimumBrightness() {
        let value = calculator.brightness(lastInteractionDate: nil, rhythmDays: 14)
        XCTAssertEqual(value, StarBrightnessCalculator.minimumBrightness, accuracy: 0.0001)
    }

    func testFreshContactIsNearFullBrightness() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let recent = now.addingTimeInterval(-86_400) // 1 day ago
        let value = calculator.brightness(lastInteractionDate: recent, rhythmDays: 14, now: now)
        XCTAssertGreaterThan(value, 0.9)
        XCTAssertLessThanOrEqual(value, 1.0)
    }

    func testOverdueRatioAtRhythmEdgeIsOne() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let past = now.addingTimeInterval(-14 * 86_400)
        let ratio = calculator.overdueRatio(lastInteractionDate: past, rhythmDays: 14, now: now)
        XCTAssertEqual(ratio, 1.0, accuracy: 0.0001)
    }
}
