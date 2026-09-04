import Foundation

/// Resolves the effective value to use for downstream references: latest actual if present,
/// otherwise planned. Planned values are never overwritten by readings.
enum MeasurementEffectiveValue {
    static func effectiveValue(for measurement: Measurement) -> Double? {
        if let actual = measurement.latestActualValue {
            return actual
        }
        if measurement.role == .derived,
           let base = measurement.sourceMeasurements.first,
           measurement.sourceMeasurements.count > 1 {
            let subtrahends = Array(measurement.sourceMeasurements.dropFirst())
            if let computed = derivedDifference(base: base, subtracting: subtrahends) {
                return computed
            }
        }
        return measurement.plannedValue
    }

    static func isWithinTolerance(measurement: Measurement, value: Double) -> Bool {
        guard let tolerance = measurement.tolerance, let planned = measurement.plannedValue else {
            return true
        }
        return abs(value - planned) <= tolerance
    }

    static func formattedEffectiveValue(for measurement: Measurement) -> String {
        MeasurementFormatter.displayValue(
            effectiveValue(for: measurement),
            unit: measurement.unit
        )
    }

    static func formattedPlannedValue(for measurement: Measurement) -> String {
        MeasurementFormatter.displayValue(
            measurement.plannedValue,
            unit: measurement.unit
        )
    }

    static func formattedLatestActual(for measurement: Measurement) -> String {
        guard let reading = measurement.latestReading else {
            return "Not measured"
        }
        let value = MeasurementFormatter.displayValue(reading.value, unit: measurement.unit)
        if reading.isPhysicallyVerified {
            return "\(value) (\(reading.phase.displayName), verified)"
        }
        return "\(value) (\(reading.phase.displayName))"
    }

    /// Computes a derived span: base effective value minus each subtrahend's effective value.
    /// Returns nil if any operand lacks a planned or actual value.
    static func derivedDifference(
        base: Measurement,
        subtracting subtrahends: [Measurement]
    ) -> Double? {
        guard var result = effectiveValue(for: base) else { return nil }
        for subtrahend in subtrahends {
            guard let value = effectiveValue(for: subtrahend) else { return nil }
            result -= value
        }
        return result
    }
}

enum MeasurementFormatter {
    static func displayValue(_ value: Double?, unit: String, precision: Int = 3) -> String {
        guard let value else { return "—" }
        let formatted = String(format: "%.\(precision)f", value)
        if unit.isEmpty {
            return formatted
        }
        return "\(formatted) \(unit)"
    }

    static func displayInches(_ value: Double?, precision: Int = 3) -> String {
        displayValue(value, unit: "in", precision: precision)
    }
}
