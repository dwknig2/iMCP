import Foundation
import SwiftData

/// A deviation or change discovered during the build. Preserves planned vs actual context.
@Model
final class ProjectChange {
    var title: String
    var changeDescription: String
    var plannedValue: String
    var actualValue: String
    var recordedAt: Date

    var project: Project?

    var discoveredAtStep: BuildStep?

    var relatedMeasurement: Measurement?

    init(
        title: String,
        changeDescription: String = "",
        plannedValue: String = "",
        actualValue: String = "",
        recordedAt: Date = .now,
        discoveredAtStep: BuildStep? = nil,
        relatedMeasurement: Measurement? = nil
    ) {
        self.title = title
        self.changeDescription = changeDescription
        self.plannedValue = plannedValue
        self.actualValue = actualValue
        self.recordedAt = recordedAt
        self.discoveredAtStep = discoveredAtStep
        self.relatedMeasurement = relatedMeasurement
    }
}
