import Foundation
import SwiftData

@Model
final class ProjectType {
    var name: String
    var typeDescription: String

    @Relationship(deleteRule: .nullify, inverse: \Project.projectType)
    var projects: [Project]

    init(name: String, typeDescription: String = "", projects: [Project] = []) {
        self.name = name
        self.typeDescription = typeDescription
        self.projects = projects
    }
}
