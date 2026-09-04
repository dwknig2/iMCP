import SwiftData
@testable import TheProjectManual
import XCTest

final class StepCompletionPolicyTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try ModelContainerFactory.makeContainer(inMemory: true)
        context = ModelContext(container)
    }

    func testCannotCompleteWhenRequiredVerificationIncomplete() throws {
        let project = makeProject()
        let step = makeStep(
            verifications: [
                VerificationCheck(title: "Frame square", kind: .physical, orderIndex: 0)
            ]
        )
        project.steps = [step]
        context.insert(project)

        XCTAssertFalse(StepCompletionPolicy.canComplete(step: step))
        XCTAssertEqual(StepCompletionPolicy.incompleteRequirements(for: step).count, 1)
    }

    func testCannotCompleteWhenDimensionalVerificationLacksMeasurement() throws {
        let project = makeProject()
        let width = Measurement(label: "Width", plannedValue: 25, unit: "in")
        let step = makeStep(
            verifications: [
                VerificationCheck(
                    title: "Width = 25\"",
                    kind: .dimensional,
                    orderIndex: 0,
                    linkedMeasurement: width
                )
            ]
        )
        step.measurements = [width]
        project.steps = [step]
        context.insert(project)

        XCTAssertFalse(StepCompletionPolicy.canComplete(step: step))
        XCTAssertTrue(
            StepCompletionPolicy.incompleteRequirements(for: step)
                .contains { $0.message.contains("physical measurement") }
        )
    }

    func testCannotCompleteWhenInputMeasurementMissing() throws {
        let project = makeProject()
        let railLength = Measurement(label: "Rail blank", plannedValue: 26.25, unit: "in")
        let step = makeStep(inputMeasurements: [railLength])
        project.steps = [step]
        context.insert(project)

        XCTAssertFalse(StepCompletionPolicy.canComplete(step: step))
        XCTAssertTrue(
            StepCompletionPolicy.incompleteRequirements(for: step)
                .contains { $0.message.contains("Rail blank") }
        )
    }

    func testCannotCompleteWhenPrerequisiteIncomplete() throws {
        let project = makeProject()
        let prerequisite = makeStep(title: "Mill stock", orderIndex: 1, status: .inProgress)
        let step = makeStep(title: "Dry-fit frame", orderIndex: 2, prerequisiteSteps: [prerequisite])
        project.steps = [prerequisite, step]
        context.insert(project)

        XCTAssertFalse(StepCompletionPolicy.canComplete(step: step))
        XCTAssertTrue(
            StepCompletionPolicy.incompleteRequirements(for: step)
                .contains { $0.message.contains("prerequisite") }
        )
    }

    func testCanCompleteWhenAllRequirementsSatisfied() throws {
        let project = makeProject()
        let prerequisite = makeStep(title: "Plane legs", orderIndex: 7, status: .completed)

        let width = Measurement(
            label: "End frame width",
            plannedValue: 25,
            unit: "in",
            readings: [
                MeasurementReading(value: 25.0, phase: .dryFit, isPhysicallyVerified: true)
            ]
        )

        let verifications = [
            VerificationCheck(title: "Shoulders seated", kind: .physical, isCompleted: true, orderIndex: 0),
            VerificationCheck(title: "Frame square", kind: .physical, isCompleted: true, orderIndex: 1),
            VerificationCheck(title: "No wind", kind: .physical, isCompleted: true, orderIndex: 2),
            VerificationCheck(
                title: "Width = 25\"",
                kind: .dimensional,
                isCompleted: true,
                orderIndex: 3,
                linkedMeasurement: width
            )
        ]

        let step = makeStep(
            title: "Dry-fit left end frame",
            orderIndex: 8,
            status: .inProgress,
            verifications: verifications,
            prerequisiteSteps: [prerequisite],
            inputMeasurements: [width],
            measurements: [width]
        )

        let next = makeStep(title: "Cut mortises", orderIndex: 9, status: .pending)
        project.steps = [prerequisite, step, next]
        context.insert(project)

        XCTAssertTrue(StepCompletionPolicy.canComplete(step: step))

        try StepCompletionPolicy.complete(step: step, in: project)
        XCTAssertEqual(step.status, .completed)
        XCTAssertEqual(next.status, .inProgress)
    }

    func testCompleteThrowsWhenRequirementsIncomplete() throws {
        let project = makeProject()
        let step = makeStep(
            verifications: [
                VerificationCheck(title: "Square", kind: .physical, orderIndex: 0)
            ]
        )
        project.steps = [step]
        context.insert(project)

        XCTAssertThrowsError(try StepCompletionPolicy.complete(step: step, in: project)) { error in
            guard case StepCompletionError.requirementsIncomplete(let requirements) = error else {
                return XCTFail("Expected requirementsIncomplete")
            }
            XCTAssertFalse(requirements.isEmpty)
        }
    }

    // MARK: - Helpers

    private func makeProject() -> Project {
        Project(title: "Test Project", status: .active)
    }

    private func makeStep(
        title: String = "Test Step",
        orderIndex: Int = 1,
        status: StepStatus = .pending,
        verifications: [VerificationCheck] = [],
        prerequisiteSteps: [BuildStep] = [],
        inputMeasurements: [TheProjectManual.Measurement] = [],
        measurements: [TheProjectManual.Measurement] = []
    ) -> BuildStep {
        BuildStep(
            title: title,
            orderIndex: orderIndex,
            status: status,
            verifications: verifications,
            prerequisiteSteps: prerequisiteSteps,
            inputMeasurements: inputMeasurements,
            measurements: measurements
        )
    }
}
