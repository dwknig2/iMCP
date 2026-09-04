import SwiftData
@testable import TheProjectManual
import XCTest

final class SampleDataTests: XCTestCase {
    func testWorkbenchFixtureHasCurrentDryFitStep() throws {
        let container = try ModelContainerFactory.makeContainer(inMemory: true)
        let context = ModelContext(container)
        let project = SampleData.makeWorkbenchProject()
        context.insert(project)

        let current = ProjectProgress.currentStep(for: project)
        XCTAssertEqual(current?.title, "Dry-fit left end frame")
        XCTAssertEqual(current?.orderIndex, 8)
        XCTAssertEqual(ProjectProgress.completedCount(for: project), 7)
    }

    func testWorkbenchTopThicknessPreservesHistoricalReadings() throws {
        let project = SampleData.makeWorkbenchProject()
        let top = project.measurements.first { $0.label == "Top thickness" }
        XCTAssertEqual(top?.plannedValue, 2.500)
        XCTAssertEqual(top?.readings.count, 2)
        XCTAssertEqual(top?.latestActualValue, 2.406)
        XCTAssertNotNil(top?.reading(for: .afterGlueUp))
    }

    func testWorkbenchLegHalfRoughCut() throws {
        let project = SampleData.makeWorkbenchProject()
        let legHalf = project.measurements.first { $0.label == "Leg half rough cut" }
        XCTAssertEqual(legHalf?.plannedValue, 34.625)
        XCTAssertEqual(legHalf?.latestActualValue, 34.625)
    }

    func testWorkbenchFinishedLegLengthIsTargetOnly() throws {
        let project = SampleData.makeWorkbenchProject()
        let finished = project.measurements.first { $0.label == "Finished laminated leg length" }
        XCTAssertEqual(finished?.plannedValue, 34.375)
        XCTAssertFalse(finished?.hasActualReading ?? true)
    }

    func testWorkbenchLegThicknessAcrossBenchHasNoInventedActuals() throws {
        let project = SampleData.makeWorkbenchProject()
        let front = project.measurements.first { $0.label == "Front leg thickness across bench" }
        let rear = project.measurements.first { $0.label == "Rear leg thickness across bench" }
        XCTAssertEqual(front?.plannedValue, 3.0)
        XCTAssertEqual(rear?.plannedValue, 3.0)
        XCTAssertFalse(front?.hasActualReading ?? true)
        XCTAssertFalse(rear?.hasActualReading ?? true)
    }

    func testWorkbenchEndFrameClearWidthUsesPhysicalDerivation() throws {
        let project = SampleData.makeWorkbenchProject()
        let clearWidth = project.measurements.first { $0.label.contains("End frame clear width") }
        XCTAssertEqual(clearWidth?.role, .derived)
        XCTAssertEqual(clearWidth?.plannedValue, 19.0)
        XCTAssertEqual(clearWidth?.sourceMeasurements.count, 3)

        let labels = Set(clearWidth?.sourceMeasurements.map(\.label) ?? [])
        XCTAssertTrue(labels.contains("Left end frame outside width"))
        XCTAssertTrue(labels.contains("Front leg thickness across bench"))
        XCTAssertTrue(labels.contains("Rear leg thickness across bench"))
    }

    func testWorkbenchClearWidthEffectiveUsesPlannedLegThickness() throws {
        let project = SampleData.makeWorkbenchProject()
        guard let clearWidth = project.measurements.first(where: { $0.label.contains("End frame clear width") }) else {
            return XCTFail("Missing clear width measurement")
        }

        XCTAssertEqual(try XCTUnwrap(MeasurementEffectiveValue.effectiveValue(for: clearWidth)), 19.0, accuracy: 0.001)
    }

    func testWorkbenchDryFitStepRequiresVerificationsBeforeCompletion() throws {
        let project = SampleData.makeWorkbenchProject()
        guard let step = ProjectProgress.currentStep(for: project) else {
            return XCTFail("Missing current step")
        }

        XCTAssertFalse(StepCompletionPolicy.canComplete(step: step))
        XCTAssertEqual(step.sortedVerifications.filter(\.isRequired).count, 4)
    }
}
