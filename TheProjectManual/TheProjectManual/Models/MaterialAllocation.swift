import Foundation
import SwiftData

/// A planned or actual cut/part allocation from stock material for a specific step.
@Model
final class MaterialAllocation {
    var partLabel: String
    var plannedCutDescription: String
    var actualCutDescription: String
    var notes: String
    var sortOrder: Int
    var isCut: Bool

    var material: Material?

    var step: BuildStep?

    init(
        partLabel: String,
        plannedCutDescription: String,
        actualCutDescription: String = "",
        notes: String = "",
        sortOrder: Int = 0,
        isCut: Bool = false
    ) {
        self.partLabel = partLabel
        self.plannedCutDescription = plannedCutDescription
        self.actualCutDescription = actualCutDescription
        self.notes = notes
        self.sortOrder = sortOrder
        self.isCut = isCut
    }
}
