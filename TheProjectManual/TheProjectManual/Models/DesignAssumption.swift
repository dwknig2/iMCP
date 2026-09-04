import Foundation
import SwiftData

/// A design assumption that informs calculations and derived dimensions.
/// Assumptions are preserved historically; `isActive` allows superseding without deletion.
@Model
final class DesignAssumption {
    var title: String
    var statement: String
    var value: String
    var unit: String
    var isActive: Bool
    var recordedAt: Date
    var sortOrder: Int

    var project: Project?

    init(
        title: String,
        statement: String,
        value: String = "",
        unit: String = "",
        isActive: Bool = true,
        recordedAt: Date = .now,
        sortOrder: Int = 0
    ) {
        self.title = title
        self.statement = statement
        self.value = value
        self.unit = unit
        self.isActive = isActive
        self.recordedAt = recordedAt
        self.sortOrder = sortOrder
    }
}
