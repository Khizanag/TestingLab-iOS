#if DEBUG
import SwiftUI

/// One change in this build: what to look at, how to try it, and an optional way there.
public struct BuildNote: Identifiable {
    public let commit: String
    public let title: LocalizedStringResource
    public let howToTest: LocalizedStringResource
    public let systemImage: String
    public let color: Color
    /// Runs after the lab closes, such as opening the screen the change is on. Nil when there's nowhere to go.
    public let action: (@MainActor @Sendable () -> Void)?

    public var id: String { commit }

    public init(
        commit: String,
        title: LocalizedStringResource,
        howToTest: LocalizedStringResource,
        systemImage: String,
        color: Color,
        action: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.commit = commit
        self.title = title
        self.howToTest = howToTest
        self.systemImage = systemImage
        self.color = color
        self.action = action
    }
}

// MARK: - Section
/// This build's changes; tapping one closes the lab and goes where it is.
struct BuildNotesSection: View {
    @Environment(\.closeTestingLab) private var closeTestingLab

    let notes: [BuildNote]

    var body: some View {
        Section {
            ForEach(notes) { note in
                if let action = note.action {
                    Button { closeTestingLab(then: action) } label: { row(note) }
                        .accessibilityHint(Text(verbatim: "Goes where this change is"))
                } else {
                    row(note)
                }
            }
        } header: {
            Text(verbatim: "In This Build")
        } footer: {
            Text(verbatim: "What changed since the last build, and how to try it. Tap a change to go where it is.")
        }
    }

    private func row(_ note: BuildNote) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            LabIcon(systemImage: note.systemImage, color: note.color)
                .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 5 }
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .foregroundStyle(.primary)
                Text(note.howToTest)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(verbatim: note.commit)
                    .font(.caption.monospaced())
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
            if note.action != nil {
                Image(systemName: "arrow.up.forward")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 4)
    }
}
#endif
