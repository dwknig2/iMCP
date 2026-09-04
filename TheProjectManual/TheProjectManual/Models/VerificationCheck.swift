import Foundation
import SwiftData

/// A verification gate that may block step completion. Dimensional checks can link
/// to a measurement that must be physically verified before the gate clears.
@Model
final class VerificationCheck {
    var title: String
    var kind: VerificationKind
    var isRequired: Bool
    var isCompleted: Bool
    var orderIndex: Int
    var expectedValueDescription: String
    var completedAt: Date?

    var step: BuildStep?

    var linkedMeasurement: Measurement?

    init(
        title: String,
        kind: VerificationKind = .physical,
        isRequired: Bool = true,
        isCompleted: Bool = false,
        orderIndex: Int,
        expectedValueDescription: String = "",
        completedAt: Date? = nil,
        linkedMeasurement: Measurement? = nil
    ) {
        self.title = title
        self.kind = kind
        self.isRequired = isRequired
        self.isCompleted = isCompleted
        self.orderIndex = orderIndex
        self.expectedValueDescription = expectedValueDescription
        self.completedAt = completedAt
        self.linkedMeasurement = linkedMeasurement
    }
}
