import SwiftData
import SwiftUI

struct ProjectListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.sortOrder) private var projects: [Project]
    @State private var isPresentingCreateSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    ContentUnavailableView(
                        "No Projects",
                        systemImage: "hammer",
                        description: Text("Create a project to start tracking your build.")
                    )
                } else {
                    List {
                        Section("Active") {
                            ForEach(activeProjects) { project in
                                NavigationLink(value: project) {
                                    ProjectRowView(project: project)
                                }
                            }
                        }

                        if !completedProjects.isEmpty {
                            Section("Completed") {
                                ForEach(completedProjects) { project in
                                    NavigationLink(value: project) {
                                        ProjectRowView(project: project)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("The Project Manual")
            .navigationDestination(for: Project.self) { project in
                ProjectDetailView(project: project)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Project", systemImage: "plus") {
                        isPresentingCreateSheet = true
                    }
                    .accessibilityLabel("Create new project")
                }
            }
            .sheet(isPresented: $isPresentingCreateSheet) {
                CreateProjectView()
            }
        }
    }

    private var activeProjects: [Project] {
        projects.filter { $0.status == .active || $0.status == .planning || $0.status == .paused }
    }

    private var completedProjects: [Project] {
        projects.filter { $0.status == .completed || $0.status == .archived }
    }
}

private struct ProjectRowView: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(project.title)
                .font(.headline)

            if let currentStep = ProjectProgress.currentStep(for: project) {
                Text("Current: \(currentStep.title)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Text(ProjectProgress.progressLabel(for: project))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProjectListView()
        .modelContainer(PreviewModelContainer.shared)
}
