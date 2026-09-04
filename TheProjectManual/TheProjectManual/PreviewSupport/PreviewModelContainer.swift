import SwiftData

enum PreviewModelContainer {
  @MainActor
  static var shared: ModelContainer = {
    do {
      let container = try ModelContainerFactory.makeContainer(inMemory: true)
      let context = ModelContext(container)
      SampleData.workbenchProject().forEach { context.insert($0) }
      try context.save()
      return container
    } catch {
      fatalError("Preview container failed: \(error)")
    }
  }()
}
