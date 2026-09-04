import Foundation
import SwiftData

/// Stock, hardware, or consumable inventory for a project.
@Model
final class Material {
    var name: String
    var stockDescription: String
    var materialRole: MaterialRole
    var nominalThickness: Double?
    var nominalWidth: Double?
    var nominalLength: Double?
    var quantityOnHand: String
    var unit: String
    var notes: String
    var sortOrder: Int

    var project: Project?

    @Relationship(deleteRule: .cascade, inverse: \MaterialAllocation.material)
    var allocations: [MaterialAllocation]

    init(
        name: String,
        stockDescription: String = "",
        materialRole: MaterialRole = .stock,
        nominalThickness: Double? = nil,
        nominalWidth: Double? = nil,
        nominalLength: Double? = nil,
        quantityOnHand: String = "",
        unit: String = "",
        notes: String = "",
        sortOrder: Int = 0,
        allocations: [MaterialAllocation] = []
    ) {
        self.name = name
        self.stockDescription = stockDescription
        self.materialRole = materialRole
        self.nominalThickness = nominalThickness
        self.nominalWidth = nominalWidth
        self.nominalLength = nominalLength
        self.quantityOnHand = quantityOnHand
        self.unit = unit
        self.notes = notes
        self.sortOrder = sortOrder
        self.allocations = allocations
    }
}
