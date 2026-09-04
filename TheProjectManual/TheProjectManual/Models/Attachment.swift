import Foundation
import SwiftData

@Model
final class Attachment {
    var fileName: String
    var caption: String
    var createdAt: Date
    var localIdentifier: String

    var project: Project?

    var step: BuildStep?

    init(
        fileName: String,
        caption: String = "",
        createdAt: Date = .now,
        localIdentifier: String = UUID().uuidString
    ) {
        self.fileName = fileName
        self.caption = caption
        self.createdAt = createdAt
        self.localIdentifier = localIdentifier
    }
}
