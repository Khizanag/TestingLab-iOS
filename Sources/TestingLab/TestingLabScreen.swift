#if DEBUG
import SwiftUI

/// The lab: this build's changes, the app's own tools, the build's identity, and a way back to a first launch.
struct TestingLabScreen<Sections: View>: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isConfirmingErase = false

    let notes: [BuildNote]
    let accent: Color
    let erase: (@MainActor () -> Void)?
    let sections: () -> Sections

    var body: some View {
        NavigationStack {
            Form {
                if !notes.isEmpty {
                    BuildNotesSection(notes: notes)
                }
                sections()
                buildSection
                eraseSection
            }
            .navigationTitle(Text(verbatim: "Testing Lab"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: {
                        Label { Text(verbatim: "Done") } icon: { Image(systemName: "checkmark") }
                    }
                    .tint(accent)
                }
            }
            .confirmationDialog(
                Text(verbatim: "Erase Everything and Quit"),
                isPresented: $isConfirmingErase,
                titleVisibility: .visible
            ) {
                Button(role: .destructive) { eraseEverythingAndQuit() } label: {
                    Text(verbatim: "Erase Everything and Quit")
                }
                Button(role: .cancel) {} label: { Text(verbatim: "Cancel") }
            } message: {
                Text(verbatim: "All data, settings, and caches are deleted and the app quits.")
            }
        }
        .environment(\.closeTestingLab, CloseTestingLabAction { [dismiss] action in
            dismiss()
            Task {
                try? await Task.sleep(for: .milliseconds(450))
                action()
            }
        })
    }
}

// MARK: - Sections
private extension TestingLabScreen {
    var buildSection: some View {
        Section {
            LabeledContent {
                Text(verbatim: version)
            } label: {
                Text(verbatim: "Version")
            }
            LabeledContent {
                Text(verbatim: Bundle.main.bundleIdentifier ?? "–")
                    .textSelection(.enabled)
            } label: {
                Text(verbatim: "Bundle ID")
            }
        } header: {
            Text(verbatim: "Build")
        }
    }

    var eraseSection: some View {
        Section {
            Button(role: .destructive) { isConfirmingErase = true } label: {
                LabRow(verbatim: "Erase Everything and Quit", systemImage: "xmark.octagon.fill", isDestructive: true)
            }
        } footer: {
            Text(verbatim: "Deletes all data, settings, and caches, then quits; open the app again for a first launch.")
        }
    }

    var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "–"
        let build = info?["CFBundleVersion"] as? String ?? "–"
        return "\(short) (\(build))"
    }
}

// MARK: - Erase
private extension TestingLabScreen {
    /// The app's own extras first, then every file and setting the app owns, then quits, so the next launch is a
    /// first launch. The Keychain outlives the app, so sign-in stays.
    func eraseEverythingAndQuit() {
        erase?()
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        let fileManager = FileManager.default
        let directories: [FileManager.SearchPathDirectory] = [
            .applicationSupportDirectory,
            .cachesDirectory,
            .documentDirectory,
        ]
        for directory in directories {
            for url in fileManager.urls(for: directory, in: .userDomainMask) {
                try? fileManager.removeItem(at: url)
            }
        }
        try? fileManager.removeItem(at: fileManager.temporaryDirectory)
        exit(0)
    }
}
#endif
