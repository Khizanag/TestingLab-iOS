#if DEBUG
import SwiftUI

/// Opens the Testing Lab from anywhere, such as a settings row: `@Environment(\.openTestingLab)`.
public struct OpenTestingLabAction: Sendable {
    public init() {}

    public func callAsFunction() {
        NotificationCenter.default.post(name: .openTestingLab, object: nil)
    }
}

/// Closes the lab, then runs an action once it's gone, so whatever the action shows isn't hidden behind the lab.
/// Read it inside an app's lab sections: `@Environment(\.closeTestingLab)`.
public struct CloseTestingLabAction: Sendable {
    let close: @MainActor @Sendable (_ then: @escaping @MainActor @Sendable () -> Void) -> Void

    public func callAsFunction(then action: @escaping @MainActor @Sendable () -> Void = {}) {
        close(action)
    }
}

// MARK: - Environment
public extension EnvironmentValues {
    @Entry var openTestingLab = OpenTestingLabAction()
    @Entry var closeTestingLab = CloseTestingLabAction { action in action() }
}

// MARK: - Notification
extension Notification.Name {
    static let openTestingLab = Notification.Name("TestingLab.open")
}
#endif
