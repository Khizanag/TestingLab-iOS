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
    ///   - sections: The app's own tools, shown between the build notes and the build info.
    func testingLab<Sections: View>(
        notes: [BuildNote] = [],
        accent: Color = .accentColor,
        erase: (@MainActor () -> Void)? = nil,
        @ViewBuilder sections: @escaping () -> Sections
    ) -> some View {
        modifier(TestingLabModifier(notes: notes, accent: accent, erase: erase, sections: sections))
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
    let sections: () -> Sections

    func body(content: Content) -> some View {
        content
            .task { isPresented = UserDefaults.standard.bool(forKey: "openTestingLab") }
            .onReceive(NotificationCenter.default.publisher(for: .openTestingLab)) { _ in
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
#endif
