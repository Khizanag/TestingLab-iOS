#if DEBUG
import SwiftUI

/// A screen the lab can open: its row, and how the app gets there.
public struct LabDestination: Identifiable {
    public let title: String
    public let systemImage: String
    public let color: Color
    /// Runs after the lab closes, so what it pushes or presents isn't hidden behind the lab.
    public let open: @MainActor () -> Void

    public var id: String { title }

    /// - Parameter title: Already in the reader's language, such as a screen's name.
    public init(title: String, systemImage: String, color: Color = .gray, open: @escaping @MainActor () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.color = color
        self.open = open
    }
}

/// Every screen the app lists, a tap away and in alphabetical order whatever order the app declares them in.
/// Put it inside one of the app's sections.
public struct AllScreens: View {
    @Environment(\.closeTestingLab) private var closeTestingLab

    private let destinations: [LabDestination]
    private let systemImage: String
    private let color: Color

    public init(
        _ destinations: [LabDestination],
        systemImage: String = "square.grid.2x2.fill",
        color: Color = .gray
    ) {
        self.destinations = Self.sorted(destinations)
        self.systemImage = systemImage
        self.color = color
    }

    public var body: some View {
        DisclosureGroup {
            ForEach(destinations) { destination in
                Button { closeTestingLab(then: destination.open) } label: {
                    LabRow(verbatim: destination.title, systemImage: destination.systemImage, color: destination.color)
                }
            }
        } label: {
            LabRow(verbatim: "All Screens", systemImage: systemImage, color: color)
        }
    }

    /// The order a person expects: case-insensitive, and "Level 2" before "Level 10".
    static func sorted(_ destinations: [LabDestination]) -> [LabDestination] {
        destinations.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }
}
#endif
