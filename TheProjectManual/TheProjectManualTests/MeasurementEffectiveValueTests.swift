@testable import TheProjectManual
import XCTest

final class MeasurementEffectiveValueTests: XCTestCase {
    func testEffectiveValuePrefersLatestActualOverPlanned() {
        let measurement = Measurement(
            label: "Top thickness",
            plannedValue: 2.500,
            unit: "in",
            readings: [
                MeasurementReading(value: 2.406, phase: .afterFlattening, isPhysicallyVerified: true)
            ]
        )

        XCTAssertEqual(MeasurementEffectiveValue.effectiveValue(for: measurement), 2.406)
    }

    func testEffectiveValueFallsBackToPlannedWhenNoReadings() {
        let measurement = Measurement(label: "Bench depth", plannedValue: 27, unit: "in")
        XCTAssertEqual(MeasurementEffectiveValue.effectiveValue(for: measurement), 27)
    }

    func testDerivedDifferenceSubtractsEffectiveOperandValues() throws {
        let outside = Measurement(label: "Outside width", plannedValue: 25, unit: "in")
        let left = Measurement(
            label: "Left leg",
            plannedValue: 3,
            unit: "in",
            readings: [MeasurementReading(value: 2.875, phase: .final, isPhysicallyVerified: true)]
        )
        let right = Measurement(
            label: "Right leg",
            plannedValue: 3,
            unit: "in",
            readings: [MeasurementReading(value: 2.875, phase: .final, isPhysicallyVerified: true)]
        )

        let result = MeasurementEffectiveValue.derivedDifference(
            base: outside,
            subtracting: [left, right]
        )
        XCTAssertEqual(try XCTUnwrap(result), 19.25, accuracy: 0.001)
    }

    func testDerivedMeasurementEffectiveValueComputesFromSources() throws {
        let outside = Measurement(label: "Outside width", plannedValue: 25, unit: "in")
        let left = Measurement(
            label: "Left leg",
            plannedValue: 3,
            unit: "in",
            readings: [MeasurementReading(value: 2.875, phase: .final)]
        )
        let right = Measurement(label: "Right leg", plannedValue: 3, unit: "in")

        let clearWidth = Measurement(
            label: "Clear width",
            role: .derived,
            plannedValue: 19,
            unit: "in",
            sourceMeasurements: [outside, left, right]
        )

        XCTAssertEqual(try XCTUnwrap(MeasurementEffectiveValue.effectiveValue(for: clearWidth)), 19.125, accuracy: 0.001)
    }

    func testToleranceCheckUsesPlannedValue() {
        let measurement = Measurement(label: "Width", plannedValue: 25, unit: "in", tolerance: 0.03125)
        XCTAssertTrue(MeasurementEffectiveValue.isWithinTolerance(measurement: measurement, value: 25.02))
        XCTAssertFalse(MeasurementEffectiveValue.isWithinTolerance(measurement: measurement, value: 25.1))
    }

    func testFormattedLatestActualShowsPhaseAndVerifiedState() {
        let measurement = Measurement(
            label: "Top thickness",
            plannedValue: 2.500,
            unit: "in",
            readings: [
                MeasurementReading(
                    value: 2.406,
                    phase: .afterFlattening,
                    isPhysicallyVerified: true
                )
            ]
        )

        let formatted = MeasurementEffectiveValue.formattedLatestActual(for: measurement)
        XCTAssertTrue(formatted.contains("2.406"))
        XCTAssertTrue(formatted.contains("verified"))
    }
}
