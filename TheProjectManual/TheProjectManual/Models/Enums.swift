import Foundation

enum ProjectStatus: String, Codable, CaseIterable, Identifiable {
    case planning
    case active
    case paused
    case completed
    case archived

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .planning: "Planning"
        case .active: "Active"
        case .paused: "Paused"
        case .completed: "Completed"
        case .archived: "Archived"
        }
    }
}

enum StepStatus: String, Codable, CaseIterable, Identifiable {
    case pending
    case inProgress
    case completed
    case skipped

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pending: "Pending"
        case .inProgress: "In Progress"
        case .completed: "Completed"
        case .skipped: "Skipped"
        }
    }

    var symbolName: String {
        switch self {
        case .pending: "circle"
        case .inProgress: "circle.dotted"
        case .completed: "checkmark.circle.fill"
        case .skipped: "arrow.uturn.forward.circle"
        }
    }
}

enum MeasurementRole: String, Codable, CaseIterable, Identifiable {
  /// Original design intent — never overwritten by as-built readings.
    case designTarget
  /// Calculated from other measurements or assumptions; stores derivation metadata.
    case derived
  /// General dimension tracked through the build with planned + actual history.
    case tracked

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .designTarget: "Design Target"
        case .derived: "Derived"
        case .tracked: "Tracked"
        }
    }
}

enum MeasurementPhase: String, Codable, CaseIterable, Identifiable {
    case rough
    case afterGlueUp
    case afterFlattening
    case afterCut
    case dryFit
    case final
    case asBuilt

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rough: "Rough"
        case .afterGlueUp: "After Glue-Up"
        case .afterFlattening: "After Flattening"
        case .afterCut: "After Cut"
        case .dryFit: "Dry Fit"
        case .final: "Final"
        case .asBuilt: "As-Built"
        }
    }
}

enum VerificationKind: String, Codable, CaseIterable, Identifiable {
    case physical
    case dimensional
    case visual
    case material
    case procedural

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .physical: "Physical"
        case .dimensional: "Dimensional"
        case .visual: "Visual"
        case .material: "Material"
        case .procedural: "Procedural"
        }
    }
}

enum MaterialRole: String, Codable, CaseIterable, Identifiable {
    case stock
    case hardware
    case consumable
    case component

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .stock: "Stock"
        case .hardware: "Hardware"
        case .consumable: "Consumable"
        case .component: "Component"
        }
    }
}
