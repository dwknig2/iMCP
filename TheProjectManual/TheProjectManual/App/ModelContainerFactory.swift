import SwiftData

enum ModelContainerFactory {
    static let modelTypes: [any PersistentModel.Type] = [
        Project.self,
        BuildStep.self,
        VerificationCheck.self,
        DesignAssumption.self,
        Material.self,
        MaterialAllocation.self,
        Measurement.self,
        MeasurementReading.self,
        Note.self,
        Attachment.self,
        ProjectPhoto.self,
        ProjectChange.self,
        ProjectType.self
    ]

    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(modelTypes)
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
