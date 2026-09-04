import SwiftData
import SwiftUI

struct VerificationChecklistView: View {
    let step: BuildStep
    var onToggle: ((VerificationCheck, Bool) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Verify")
                .font(.headline)

            ForEach(step.sortedVerifications, id: \.persistentModelID) { verification in
                VerificationCheckRow(
                    verification: verification,
                    onToggle: { isCompleted in
                        onToggle?(verification, isCompleted)
                    }
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Verification checklist")
    }
}

private struct VerificationCheckRow: View {
    let verification: VerificationCheck
    let onToggle: (Bool) -> Void

    var body: some View {
        Button {
            onToggle(!verification.isCompleted)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: verification.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(verification.title)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 6) {
                        Label(verification.kind.displayName, systemImage: kindSymbol)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if verification.isRequired {
                            Text("Required")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.quaternary, in: Capsule())
                        }
                    }

                    if !verification.expectedValueDescription.isEmpty {
                        Text(verification.expectedValueDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let measurement = verification.linkedMeasurement {
                        Text("Linked: \(measurement.label) — \(MeasurementEffectiveValue.formattedLatestActual(for: measurement))")
                            .font(.caption)
                            .foregroundStyle(measurement.hasActualReading ? Color.secondary : .orange)
                    }
                }

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(verification.isCompleted ? .isSelected : [])
    }

    private var kindSymbol: String {
        switch verification.kind {
        case .physical: "hand.raised"
        case .dimensional: "ruler"
        case .visual: "eye"
        case .material: "shippingbox"
        case .procedural: "list.bullet.clipboard"
        }
    }

    private var accessibilityLabel: String {
        let state = verification.isCompleted ? "completed" : "not completed"
        return "\(verification.title), \(state), \(verification.kind.displayName)"
    }
}

#Preview {
    let container = PreviewModelContainer.shared
    let project = try! container.mainContext.fetch(FetchDescriptor<Project>()).first!
    let step = ProjectProgress.currentStep(for: project)!
    return VerificationChecklistView(step: step)
        .padding()
        .modelContainer(container)
}
