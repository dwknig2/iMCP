import Foundation
import SwiftData

/// A dimension tracked through the build. Planned values are preserved; actual values
/// accumulate as append-only readings with phase labels (rough, after glue-up, final, etc.).
@Model
final class Measurement {
    var label: String
    var role: MeasurementRole
    var plannedValue: Double?
    var unit: String
    var tolerance: Double?
    var derivationDescription: String
    var createdAt: Date
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \MeasurementReading.measurement)
    var readings: [MeasurementReading]

    var project: Project?

    /// Measurements this derived value depends on (e.g. outside span minus component thicknesses).
    @Relationship(deleteRule: .nullify)
    var sourceMeasurements: [Measurement]

    /// Steps that require a reading on this measurement before they can proceed.
    @Relationship(inverse: \BuildStep.inputMeasurements)
    var consumingSteps: [BuildStep]

    @Relationship(inverse: \VerificationCheck.linkedMeasurement)
    var linkedVerifications: [VerificationCheck]

    @Relationship(inverse: \ProjectChange.relatedMeasurement)
    var relatedChanges: [ProjectChange]

    init(
        label: String,
        role: MeasurementRole = .tracked,
        plannedValue: Double? = nil,
        unit: String = "",
        tolerance: Double? = nil,
        derivationDescription: String = "",
        createdAt: Date = .now,
        sortOrder: Int = 0,
        readings: [MeasurementReading] = [],
        sourceMeasurements: [Measurement] = []
    ) {
        self.label = label
        self.role = role
        self.plannedValue = plannedValue
        self.unit = unit
        self.tolerance = tolerance
        self.derivationDescription = derivationDescription
        self.createdAt = createdAt
        self.sortOrder = sortOrder
        self.readings = readings
        self.sourceMeasurements = sourceMeasurements
        self.consumingSteps = []
        self.linkedVerifications = []
        self.relatedChanges = []
    }

    var sortedReadings: [MeasurementReading] {
        readings.sorted { lhs, rhs in
            if lhs.recordedAt != rhs.recordedAt {
                return lhs.recordedAt > rhs.recordedAt
            }
            return lhs.phase.rawValue < rhs.phase.rawValue
        }
    }

    var latestReading: MeasurementReading? {
        sortedReadings.first
    }

    var latestActualValue: Double? {
        latestReading?.value
    }

    var hasActualReading: Bool {
        !readings.isEmpty
    }

    func reading(for phase: MeasurementPhase) -> MeasurementReading? {
        readings
            .filter { $0.phase == phase }
            .sorted { $0.recordedAt > $1.recordedAt }
            .first
    }
}

/// Append-only actual measurement history. Never overwrites planned values on the parent.
@Model
final class MeasurementReading {
    var value: Double
    var phase: MeasurementPhase
    var note: String
    var recordedAt: Date
    var isPhysicallyVerified: Bool

    var measurement: Measurement?

    init(
        value: Double,
        phase: MeasurementPhase = .asBuilt,
        note: String = "",
        recordedAt: Date = .now,
        isPhysicallyVerified: Bool = false
    ) {
        self.value = value
        self.phase = phase
        self.note = note
        self.recordedAt = recordedAt
        self.isPhysicallyVerified = isPhysicallyVerified
    }
}
