import Foundation

enum ProjectLifecycle {
    static func markCompleted(_ project: Project, at date: Date = .now) {
        project.status = .completed
        project.completedAt = date
    }

    static func archive(_ project: Project) {
        project.status = .archived
    }

    static func reactivate(_ project: Project) {
        guard project.status == .paused || project.status == .planning else { return }
        project.status = .active
    }
}
