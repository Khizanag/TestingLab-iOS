#if DEBUG
import SwiftUI

public extension View {
    /// Adds the Testing Lab over this view. It opens on a shake, from ``OpenTestingLabAction``, or at launch with
    /// the `-openTestingLab YES` argument. Debug builds only: wrap the call in `#if DEBUG`.
    ///
    /// - Parameters:
    ///   - notes: What this build changed, listed first so a tester knows what to try.
    ///   - accent: The app's accent, for the Done button.
    ///   - erase: Deletes what the lab can't find on its own, such as an App Group store, before Erase Everything
    ///     removes the app's files and settings and quits.
    ///   - isEnabled: Whether this host answers a request to open. An app that hosts the lab on each full-screen
    ///     flow as well as its root turns the root's off while a flow covers it: only one sheet can open at a time,
    ///     and one from below a cover never shows.
    ///   - sections: The app's own tools, shown between the build notes and the build info.
    func testingLab<Sections: View>(
        notes: [BuildNote] = [],
        accent: Color = .accentColor,
        erase: (@MainActor () -> Void)? = nil,
        isEnabled: Bool = true,
        @ViewBuilder sections: @escaping () -> Sections
    ) -> some View {
        modifier(
            TestingLabModifier(notes: notes, accent: accent, erase: erase, isEnabled: isEnabled, sections: sections)
        )
    }
}

private struct TestingLabModifier<Sections: View>: ViewModifier {
    @State private var isPresented = false
    /// Runs once the sheet has finished closing: anything pushed or presented while it's still animating away can
    /// come out blank.
    @State private var afterClose: (@MainActor () -> Void)?

    let notes: [BuildNote]
    let accent: Color
    let erase: (@MainActor () -> Void)?
    let isEnabled: Bool
    let sections: () -> Sections

    func body(content: Content) -> some View {
        content
            .task(id: isEnabled) {
                guard isEnabled, LaunchOpening.claim() else { return }
                isPresented = UserDefaults.standard.bool(forKey: "openTestingLab")
            }
            .onReceive(NotificationCenter.default.publisher(for: .openTestingLab)) { _ in
                guard isEnabled else { return }
                isPresented = true
            }
            .sheet(isPresented: $isPresented, onDismiss: runAfterClose) {
                TestingLabScreen(notes: notes, accent: accent, erase: erase, sections: sections)
                    .environment(\.closeTestingLab, CloseTestingLabAction { action in
                        afterClose = action
                        isPresented = false
                    })
            }
    }

    private func runAfterClose() {
        let action = afterClose
        afterClose = nil
        action?()
    }
}

// MARK: - Launch
/// `-openTestingLab YES` opens the lab once per launch. An app that hosts the lab in more than one place, such as
/// on each full-screen flow so it can open above them, would otherwise open it again with every host that appears.
enum LaunchOpening {
    private static var isClaimed = false

    /// True for the first host that asks, false for every later one.
    static func claim() -> Bool {
        defer { isClaimed = true }
        return !isClaimed
    }
}
#endif
