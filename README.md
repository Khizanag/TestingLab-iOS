# TestingLab

A developer screen for iOS apps: shake the device and a lab opens over the app with what this build changed, the app's own tools, the build's identity, and a way back to a first launch. Debug builds only — Release builds don't contain it.

## Add it

Add the package to the app, then link the `TestingLab` product:

```swift
.package(url: "https://github.com/Khizanag/TestingLab-iOS", from: "1.0.0")
// target dependency:
.product(name: "TestingLab", package: "TestingLab-iOS")
```

## Use it

Attach the lab at the app's root, inside `#if DEBUG`:

```swift
import TestingLab

ContentView()
    #if DEBUG
    .testingLab(notes: BuildNotes.current, accent: .green) {
        Section("Progress") {
            Button { xp.award(100) } label: {
                LabRow("Add 100 XP", systemImage: "plus", color: .orange)
            }
        }
    }
    #endif
```

| Piece | What it does |
|---|---|
| `testingLab(notes:accent:erase:isEnabled:sections:)` | Opens the lab on a shake, from `openTestingLab`, or at launch with `-openTestingLab YES` |
| `BuildNote` | One change in this build: title, how to test it, and an optional action that goes where it is |
| `AllScreens`, `LabDestination` | A disclosure row listing every screen the app names, always alphabetical; a tap closes the lab, then opens it |
| `LabRow`, `LabIcon` | Settings-style rows: a colored icon square; destructive rows are red in both icon and title |
| `@Environment(\.openTestingLab)` | Opens the lab from anywhere, such as a settings row |
| `@Environment(\.closeTestingLab)` | Inside the app's sections: closes the lab, then runs an action so what it shows is visible |

An app with full-screen flows can host the lab on each flow's root as well as its own root, so it opens above them. Only one sheet can open at a time and one from below a cover never shows, so pass `isEnabled: false` to the root's host while a flow covers it. The launch argument opens the lab once, however many hosts there are.

The lab always adds a **Build** section (version, bundle ID) and **Erase Everything and Quit**, which deletes the app's settings, Application Support, Caches, Documents, and temporary files, then quits. Pass `erase:` for anything else, such as a store in an App Group container.

## Develop

```sh
swift test
swiftlint --strict
```

Requires iOS 26 and Swift 6.2. The macOS platform is declared only so `swift test` runs on the Mac.
