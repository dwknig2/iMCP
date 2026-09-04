import Foundation
import SwiftData

@Model
final class Project {
    var title: String
    var projectDescription: String
    var status: ProjectStatus
    var createdAt: Date
    var completedAt: Date?
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \BuildStep.project)
    var steps: [BuildStep]

    @Relationship(deleteRule: .cascade, inverse: \DesignAssumption.project)
    var assumptions: [DesignAssumption]

    @Relationship(deleteRule: .cascade, inverse: \Material.project)
    var materials: [Material]

    @Relationship(deleteRule: .cascade, inverse: \Measurement.project)
    var measurements: [Measurement]

    @Relationship(deleteRule: .cascade, inverse: \Note.project)
    var notes: [Note]

    @Relationship(deleteRule: .cascade, inverse: \ProjectPhoto.project)
    var photos: [ProjectPhoto]

    @Relationship(deleteRule: .cascade, inverse: \ProjectChange.project)
    var changes: [ProjectChange]

    @Relationship(deleteRule: .cascade, inverse: \Attachment.project)
    var attachments: [Attachment]

    var projectType: ProjectType?

    init(
        title: String,
        projectDescription: String = "",
        status: ProjectStatus = .planning,
        createdAt: Date = .now,
        completedAt: Date? = nil,
        sortOrder: Int = 0,
        steps: [BuildStep] = [],
        assumptions: [DesignAssumption] = [],
        materials: [Material] = [],
        measurements: [Measurement] = [],
        notes: [Note] = [],
        photos: [ProjectPhoto] = [],
        changes: [ProjectChange] = [],
        attachments: [Attachment] = [],
        projectType: ProjectType? = nil
    ) {
        self.title = title
        self.projectDescription = projectDescription
        self.status = status
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.sortOrder = sortOrder
        self.steps = steps
        self.assumptions = assumptions
        self.materials = materials
        self.measurements = measurements
        self.notes = notes
        self.photos = photos
        self.changes = changes
        self.attachments = attachments
        self.projectType = projectType
    }

    var sortedSteps: [BuildStep] {
        steps.sorted { $0.orderIndex < $1.orderIndex }
    }

    var isHistoricalRecord: Bool {
        status == .completed || status == .archived
    }
}
