import Foundation
import SwiftData

@Model
final class Note {
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date

    var project: Project?

    var step: BuildStep?

    init(
        title: String = "",
        body: String,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
