import SwiftData
import SwiftUI

struct NextStepView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let project: Project
    @Bindable var step: BuildStep

    @State private var showDetails = false
    @State private var completionError: String?

    private var requirements: [StepCompletionRequirement] {
        StepCompletionPolicy.incompleteRequirements(for: step)
    }

    private var canComplete: Bool {
        requirements.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ProgressHeaderView(project: project)

                VStack(alignment: .leading, spacing: 8) {
                    Text("CURRENT STEP")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(step.title)
                        .font(.title.weight(.semibold))

                    if !step.targetDescription.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Target")
                                .font(.subheadline.weight(.semibold))
                            Text(step.targetDescription)
                                .font(.body)
                        }
                    }
                }

                RequirementBannerView(requirements: requirements)

                if !step.verifications.isEmpty {
                    VerificationChecklistView(step: step) { verification, isCompleted in
                        StepCompletionPolicy.toggleVerification(verification, isCompleted: isCompleted)
                        try? modelContext.save()
                    }
                }

                if !step.measurements.isEmpty {
                    MeasurementSummaryView(measurements: step.measurements)
                }

                if !step.materialAllocations.isEmpty {
                    MaterialAllocationSummaryView(allocations: step.sortedMaterialAllocations)
                }

                if showDetails {
                    StepDetailsSection(step: step)
                }

                actionButtons
            }
            .padding()
        }
        .navigationTitle("Next Step")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Cannot Complete Step", isPresented: Binding(
            get: { completionError != nil },
            set: { if !$0 { completionError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(completionError ?? "")
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(showDetails ? "Hide Details" : "Details") {
                withAnimation { showDetails.toggle() }
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)

            HStack(spacing: 12) {
                if let previous = ProjectProgress.previousStep(before: step, in: project) {
                    NavigationLink {
                        NextStepView(project: project, step: previous)
                    } label: {
                        Text("Previous")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                Button("Complete Step") {
                    completeStep()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .disabled(!canComplete || step.status == .completed || project.isHistoricalRecord)
                .accessibilityLabel(canComplete ? "Complete step" : "Complete step disabled, requirements incomplete")
            }
        }
        .padding(.top, 8)
    }

    private func completeStep() {
        do {
            try StepCompletionPolicy.complete(step: step, in: project)
            try modelContext.save()
            dismiss()
        } catch StepCompletionError.requirementsIncomplete(let remaining) {
            completionError = remaining.map(\.message).joined(separator: "\n")
        } catch {
            completionError = error.localizedDescription
        }
    }
}

private struct StepDetailsSection: View {
    let step: BuildStep

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !step.instructions.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Instructions")
                        .font(.headline)
                    Text(step.instructions)
                        .font(.body)
                }
            }

            if !step.notes.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes")
                        .font(.headline)
                    ForEach(step.notes, id: \.persistentModelID) { note in
                        Text(note.body)
                            .font(.body)
                    }
                }
            }

            if !step.photos.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Photos")
                        .font(.headline)
                    ForEach(step.photos, id: \.persistentModelID) { photo in
                        Label(photo.caption.isEmpty ? "Photo" : photo.caption, systemImage: "photo")
                            .font(.subheadline)
                    }
                }
            }

            if !step.attachments.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Attachments")
                        .font(.headline)
                    ForEach(step.attachments, id: \.persistentModelID) { attachment in
                        Label(attachment.fileName, systemImage: "doc")
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding(12)
        .background(.quaternary.opacity(0.25), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct MaterialAllocationSummaryView: View {
    let allocations: [MaterialAllocation]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Material Allocations")
                .font(.headline)

            ForEach(allocations, id: \.persistentModelID) { allocation in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(allocation.partLabel)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        if allocation.isCut {
                            Label("Cut", systemImage: "scissors")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let material = allocation.material {
                        Text(material.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text("Planned: \(allocation.plannedCutDescription)")
                        .font(.caption)

                    if !allocation.actualCutDescription.isEmpty {
                        Text("Actual: \(allocation.actualCutDescription)")
                            .font(.caption.monospacedDigit())
                    }
                }
                .padding(12)
                .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    let container = PreviewModelContainer.shared
    let project = try! container.mainContext.fetch(FetchDescriptor<Project>()).first!
    let step = ProjectProgress.currentStep(for: project)!
    return NavigationStack {
        NextStepView(project: project, step: step)
    }
    .modelContainer(container)
}
