import Foundation
import SwiftData

@Model
final class ProjectPhoto {
    var caption: String
    var createdAt: Date
    var localIdentifier: String

    var project: Project?

    var step: BuildStep?

    init(
        caption: String = "",
        createdAt: Date = .now,
        localIdentifier: String = UUID().uuidString
    ) {
        self.caption = caption
        self.createdAt = createdAt
        self.localIdentifier = localIdentifier
    }
}
