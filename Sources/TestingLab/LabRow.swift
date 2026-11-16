#if DEBUG
import SwiftUI

/// A lab row as the system Settings app draws one: a colored icon square and the title in the primary color.
/// A row that deletes is red in both, so it reads as one at a glance.
public struct LabRow: View {
    private let title: Text
    private let systemImage: String
    private let color: Color
    private let isDestructive: Bool

    /// - Parameter color: Tells rows apart; ignored when the row is destructive, which is always red.
    public init(
        _ title: LocalizedStringKey,
        systemImage: String,
        color: Color = .gray,
        isDestructive: Bool = false
    ) {
        self.title = Text(title)
        self.systemImage = systemImage
        self.color = color
        self.isDestructive = isDestructive
    }

    /// A title that's already in the reader's language, such as a screen's name.
    public init(verbatim title: String, systemImage: String, color: Color = .gray, isDestructive: Bool = false) {
        self.title = Text(verbatim: title)
        self.systemImage = systemImage
        self.color = color
        self.isDestructive = isDestructive
    }

    public var body: some View {
        Label {
            title
                .foregroundStyle(isDestructive ? Color.red : Color.primary)
        } icon: {
            LabIcon(systemImage: systemImage, color: isDestructive ? .red : color)
        }
    }
}

/// The small colored square that leads a lab row, with a white symbol.
public struct LabIcon: View {
    @ScaledMetric(relativeTo: .body) private var side: CGFloat = 28

    private let systemImage: String
    private let color: Color

    public init(systemImage: String, color: Color) {
        self.systemImage = systemImage
        self.color = color
    }

    public var body: some View {
        Image(systemName: systemImage)
            .font(.footnote.weight(.semibold))
            // A color, not the hierarchical `.primary`, which a button would turn into its tint; read in the dark
            // scheme, so the symbol stays light on any square's color.
            .foregroundStyle(Color.primary)
            .environment(\.colorScheme, .dark)
            .frame(width: side, height: side)
            .background(color, in: .rect(cornerRadius: 8, style: .continuous))
            .accessibilityHidden(true)
    }
}
#endif
