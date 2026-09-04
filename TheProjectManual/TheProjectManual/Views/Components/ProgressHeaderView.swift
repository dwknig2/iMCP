import SwiftData
import SwiftUI

struct ProgressHeaderView: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.title)
                .font(.title2.weight(.semibold))

            HStack(spacing: 8) {
                Label(project.status.displayName, systemImage: statusSymbol)
                    .font(.subheadline)
                    .accessibilityLabel("Project status \(project.status.displayName)")

                Text("•")
                    .foregroundStyle(.secondary)

                Text(ProjectProgress.progressLabel(for: project))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusSymbol: String {
        switch project.status {
        case .planning: "pencil"
        case .active: "hammer"
        case .paused: "pause.circle"
        case .completed: "checkmark.seal"
        case .archived: "archivebox"
        }
    }
}

#Preview {
    let container = PreviewModelContainer.shared
    let project = try! container.mainContext.fetch(FetchDescriptor<Project>()).first!
    return ProgressHeaderView(project: project)
        .padding()
        .modelContainer(container)
}
