import Foundation
import SwiftData

@Model
final class BuildStep {
    var title: String
    var instructions: String
    var orderIndex: Int
    var status: StepStatus
    var targetDescription: String
    var completedAt: Date?

    var project: Project?

    @Relationship(deleteRule: .cascade, inverse: \VerificationCheck.step)
    var verifications: [VerificationCheck]

    /// Steps that must be completed before this step can start or complete.
    @Relationship(deleteRule: .nullify)
    var prerequisiteSteps: [BuildStep]

    /// Measurements that must have at least one actual reading before this step can complete.
    @Relationship(deleteRule: .nullify)
    var inputMeasurements: [Measurement]

    @Relationship(deleteRule: .nullify)
    var measurements: [Measurement]

    @Relationship(deleteRule: .cascade, inverse: \MaterialAllocation.step)
    var materialAllocations: [MaterialAllocation]

    @Relationship(deleteRule: .cascade, inverse: \Note.step)
    var notes: [Note]

    @Relationship(deleteRule: .cascade, inverse: \ProjectPhoto.step)
    var photos: [ProjectPhoto]

    @Relationship(deleteRule: .cascade, inverse: \Attachment.step)
    var attachments: [Attachment]

    @Relationship(deleteRule: .nullify, inverse: \ProjectChange.discoveredAtStep)
    var discoveredChanges: [ProjectChange]

    init(
        title: String,
        instructions: String = "",
        orderIndex: Int,
        status: StepStatus = .pending,
        targetDescription: String = "",
        completedAt: Date? = nil,
        verifications: [VerificationCheck] = [],
        prerequisiteSteps: [BuildStep] = [],
        inputMeasurements: [Measurement] = [],
        measurements: [Measurement] = [],
        materialAllocations: [MaterialAllocation] = [],
        notes: [Note] = [],
        photos: [ProjectPhoto] = [],
        attachments: [Attachment] = []
    ) {
        self.title = title
        self.instructions = instructions
        self.orderIndex = orderIndex
        self.status = status
        self.targetDescription = targetDescription
        self.completedAt = completedAt
        self.verifications = verifications
        self.prerequisiteSteps = prerequisiteSteps
        self.inputMeasurements = inputMeasurements
        self.measurements = measurements
        self.materialAllocations = materialAllocations
        self.notes = notes
        self.photos = photos
        self.attachments = attachments
        self.discoveredChanges = []
    }

    var sortedVerifications: [VerificationCheck] {
        verifications.sorted { $0.orderIndex < $1.orderIndex }
    }

    var sortedMaterialAllocations: [MaterialAllocation] {
        materialAllocations.sorted { $0.sortOrder < $1.sortOrder }
    }
}
