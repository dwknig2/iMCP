import SwiftData
import SwiftUI

@main
struct TheProjectManualApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainerFactory.makeContainer()
            seedIfNeeded(in: container)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ProjectListView()
        }
        .modelContainer(container)
    }

    private func seedIfNeeded(in container: ModelContainer) {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Project>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        SampleData.workbenchProject().forEach { project in
            context.insert(project)
        }
        try? context.save()
    }
}
