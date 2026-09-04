import Foundation

struct StepCompletionRequirement: Identifiable, Equatable {
    let id: String
    let message: String
}

/// Domain rules for verification-gated step completion and prerequisite enforcement.
enum StepCompletionPolicy {
    static func canComplete(step: BuildStep) -> Bool {
        incompleteRequirements(for: step).isEmpty
    }

    static func incompleteRequirements(for step: BuildStep) -> [StepCompletionRequirement] {
        var requirements: [StepCompletionRequirement] = []

        for prerequisite in step.prerequisiteSteps where prerequisite.status != .completed {
            requirements.append(
                StepCompletionRequirement(
                    id: "prerequisite-\(prerequisite.persistentModelID)",
                    message: "Complete prerequisite: \(prerequisite.title)"
                )
            )
        }

        for verification in step.sortedVerifications where verification.isRequired && !verification.isCompleted {
            if let measurement = verification.linkedMeasurement,
               verification.kind == .dimensional,
               !measurement.hasActualReading {
                requirements.append(
                    StepCompletionRequirement(
                        id: "verification-measurement-\(verification.persistentModelID)",
                        message: "\(verification.title) requires a physical measurement"
                    )
                )
            } else {
                requirements.append(
                    StepCompletionRequirement(
                        id: "verification-\(verification.persistentModelID)",
                        message: "Verify: \(verification.title)"
                    )
                )
            }
        }

        for measurement in step.inputMeasurements where !measurement.hasActualReading {
            requirements.append(
                StepCompletionRequirement(
                    id: "input-measurement-\(measurement.persistentModelID)",
                    message: "Record actual value for \(measurement.label)"
                )
            )
        }

        return requirements
    }

    static func complete(step: BuildStep, in project: Project, at date: Date = .now) throws {
        let requirements = incompleteRequirements(for: step)
        guard requirements.isEmpty else {
            throw StepCompletionError.requirementsIncomplete(requirements)
        }

        step.status = .completed
        step.completedAt = date
        ProjectProgress.advanceToNextStep(after: step, in: project)
    }

    static func toggleVerification(
        _ verification: VerificationCheck,
        isCompleted: Bool,
        at date: Date = .now
    ) {
        verification.isCompleted = isCompleted
        verification.completedAt = isCompleted ? date : nil

        if isCompleted,
           verification.kind == .dimensional,
           let measurement = verification.linkedMeasurement,
           let latest = measurement.latestReading,
           latest.isPhysicallyVerified == false {
            latest.isPhysicallyVerified = true
        }
    }
}

enum StepCompletionError: Error, Equatable {
    case requirementsIncomplete([StepCompletionRequirement])
}
