import SwiftData
import SwiftUI

struct CreateProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var projectDescription = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Project") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $projectDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createProject()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func createProject() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let project = Project(
            title: trimmedTitle,
            projectDescription: projectDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            status: .active,
            sortOrder: Int(Date().timeIntervalSince1970)
        )

        let firstStep = BuildStep(
            title: "Define project scope",
            instructions: "Capture design assumptions, materials, and the first build step.",
            orderIndex: 1,
            status: .inProgress
        )
        project.steps = [firstStep]

        modelContext.insert(project)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    CreateProjectView()
        .modelContainer(PreviewModelContainer.shared)
}
