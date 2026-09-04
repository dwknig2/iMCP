import Foundation

enum ProjectProgress {
    static func sortedSteps(for project: Project) -> [BuildStep] {
        project.sortedSteps
    }

    static func currentStep(for project: Project) -> BuildStep? {
        sortedSteps(for: project).first { step in
            step.status != .completed && step.status != .skipped
        }
    }

    static func previousStep(before step: BuildStep, in project: Project) -> BuildStep? {
        let steps = sortedSteps(for: project)
        guard let index = steps.firstIndex(where: { $0.persistentModelID == step.persistentModelID }),
              index > 0 else {
            return nil
        }
        return steps[index - 1]
    }

    static func completedCount(for project: Project) -> Int {
        sortedSteps(for: project).filter { $0.status == .completed }.count
    }

    static func totalCount(for project: Project) -> Int {
        project.steps.count
    }

    static func progressLabel(for project: Project) -> String {
        "\(completedCount(for: project)) / \(totalCount(for: project)) steps"
    }

    static func advanceToNextStep(after completedStep: BuildStep, in project: Project) {
        let steps = sortedSteps(for: project)
        guard let index = steps.firstIndex(where: { $0.persistentModelID == completedStep.persistentModelID }) else {
            return
        }

        let remaining = steps.dropFirst(index + 1)
        if let next = remaining.first(where: { $0.status != .completed && $0.status != .skipped }) {
            if next.status == .pending {
                next.status = .inProgress
            }
        } else if project.status == .active {
            project.status = .completed
            project.completedAt = .now
        }
    }
}
