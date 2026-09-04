import SwiftData
import SwiftData
import SwiftUI

struct ProjectDetailView: View {
    @Bindable var project: Project

    var body: some View {
        List {
            Section {
                ProgressHeaderView(project: project)

                if let currentStep = ProjectProgress.currentStep(for: project) {
                    NavigationLink {
                        NextStepView(project: project, step: currentStep)
                    } label: {
                        Label("Continue: \(currentStep.title)", systemImage: "arrow.right.circle.fill")
                            .font(.headline)
                    }
                    .accessibilityLabel("Continue current step: \(currentStep.title)")
                }
            }

            if !project.assumptions.isEmpty {
                Section("Design Assumptions") {
                    ForEach(project.assumptions.sorted { $0.sortOrder < $1.sortOrder }, id: \.persistentModelID) { assumption in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(assumption.title)
                                .font(.subheadline.weight(.medium))
                            Text(assumption.statement)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !assumption.value.isEmpty {
                                Text("\(assumption.value) \(assumption.unit)".trimmingCharacters(in: .whitespaces))
                                    .font(.caption.monospacedDigit())
                            }
                        }
                    }
                }
            }

            Section("Build Steps") {
                ForEach(ProjectProgress.sortedSteps(for: project), id: \.persistentModelID) { step in
                    NavigationLink {
                        NextStepView(project: project, step: step)
                    } label: {
                        StepRowView(step: step, isCurrent: step.persistentModelID == ProjectProgress.currentStep(for: project)?.persistentModelID)
                    }
                }
            }

            if !project.changes.isEmpty {
                Section("Deviations") {
                    ForEach(project.changes.sorted { $0.recordedAt > $1.recordedAt }, id: \.persistentModelID) { change in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(change.title)
                                .font(.subheadline.weight(.medium))
                            if !change.changeDescription.isEmpty {
                                Text(change.changeDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text("Planned: \(change.plannedValue) → Actual: \(change.actualValue)")
                                .font(.caption.monospacedDigit())
                        }
                    }
                }
            }

            if project.status == .active {
                Section {
                    Button("Mark Project Complete") {
                        ProjectLifecycle.markCompleted(project)
                    }
                    .foregroundStyle(.green)
                }
            }
        }
        .navigationTitle("Overview")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StepRowView: View {
    let step: BuildStep
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: step.status.symbolName)
                .foregroundStyle(isCurrent ? .primary : .secondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.body)

                if isCurrent {
                    Text("Current step")
                        .font(.caption.weight(.semibold))
                } else {
                    Text(step.status.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityLabel("\(step.title), \(isCurrent ? "current step" : step.status.displayName)")
    }
}

#Preview {
    let container = PreviewModelContainer.shared
    let project = try! container.mainContext.fetch(FetchDescriptor<Project>()).first!
    return NavigationStack {
        ProjectDetailView(project: project)
    }
    .modelContainer(container)
}
