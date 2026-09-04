import SwiftData
@testable import TheProjectManual
import XCTest

final class ProjectProgressTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try ModelContainerFactory.makeContainer(inMemory: true)
        context = ModelContext(container)
    }

    func testCurrentStepIsFirstIncompleteStep() throws {
        let project = Project(title: "Workbench", status: .active)
        let step1 = BuildStep(title: "Glue up", orderIndex: 1, status: .completed)
        let step2 = BuildStep(title: "Dry-fit", orderIndex: 2, status: .inProgress)
        let step3 = BuildStep(title: "Mortises", orderIndex: 3, status: .pending)
        project.steps = [step3, step1, step2]
        context.insert(project)

        let current = ProjectProgress.currentStep(for: project)
        XCTAssertEqual(current?.title, "Dry-fit")
    }

    func testProgressLabelCountsCompletedSteps() throws {
        let project = Project(title: "Workbench", status: .active)
        project.steps = [
            BuildStep(title: "A", orderIndex: 1, status: .completed),
            BuildStep(title: "B", orderIndex: 2, status: .completed),
            BuildStep(title: "C", orderIndex: 3, status: .inProgress)
        ]
        context.insert(project)

        XCTAssertEqual(ProjectProgress.progressLabel(for: project), "2 / 3 steps")
    }

    func testAdvanceToNextStepMarksNextInProgress() throws {
        let project = Project(title: "Workbench", status: .active)
        let step1 = BuildStep(title: "Dry-fit", orderIndex: 1, status: .completed)
        let step2 = BuildStep(title: "Mortises", orderIndex: 2, status: .pending)
        project.steps = [step1, step2]
        context.insert(project)

        ProjectProgress.advanceToNextStep(after: step1, in: project)
        XCTAssertEqual(step2.status, .inProgress)
    }

    func testCompletingFinalStepMarksProjectCompleted() throws {
        let project = Project(title: "Workbench", status: .active)
        let step1 = BuildStep(title: "Final cleanup", orderIndex: 1, status: .completed)
        project.steps = [step1]
        context.insert(project)

        ProjectProgress.advanceToNextStep(after: step1, in: project)
        XCTAssertEqual(project.status, .completed)
        XCTAssertNotNil(project.completedAt)
    }
}
