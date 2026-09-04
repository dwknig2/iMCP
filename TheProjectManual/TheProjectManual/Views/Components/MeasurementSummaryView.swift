import SwiftData
import SwiftUI

struct MeasurementSummaryView: View {
    let measurements: [Measurement]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Relevant Measurements")
                .font(.headline)

            ForEach(measurements.sorted { $0.sortOrder < $1.sortOrder }, id: \.persistentModelID) { measurement in
                MeasurementRowView(measurement: measurement)
            }
        }
    }
}

struct MeasurementRowView: View {
    let measurement: Measurement

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(measurement.label)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(measurement.role.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Planned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(MeasurementEffectiveValue.formattedPlannedValue(for: measurement))
                        .font(.body.monospacedDigit())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(measurement.hasActualReading ? "Actual" : "Not measured")
                        .font(.caption)
                        .foregroundStyle(measurement.hasActualReading ? Color.secondary : .orange)
                    Text(MeasurementEffectiveValue.formattedLatestActual(for: measurement))
                        .font(.body.monospacedDigit())
                        .foregroundStyle(measurement.hasActualReading ? Color.primary : .orange)
                }
            }

            if measurement.role == .derived, !measurement.derivationDescription.isEmpty {
                Text(measurement.derivationDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if measurement.readings.count > 1 {
                DisclosureGroup("History (\(measurement.readings.count) readings)") {
                    ForEach(measurement.sortedReadings, id: \.persistentModelID) { reading in
                        HStack {
                            Text(reading.phase.displayName)
                            Spacer()
                            Text(MeasurementFormatter.displayValue(reading.value, unit: measurement.unit))
                                .monospacedDigit()
                        }
                        .font(.caption)
                    }
                }
                .font(.caption)
            }
        }
        .padding(12)
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let container = PreviewModelContainer.shared
    let project = try! container.mainContext.fetch(FetchDescriptor<Project>()).first!
    let step = ProjectProgress.currentStep(for: project)!
    return MeasurementSummaryView(measurements: step.measurements)
        .padding()
        .modelContainer(container)
}
