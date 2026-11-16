# CLAUDE.md — TestingLab

A debug-only developer screen shared by my iOS apps. One Swift package, one product: `TestingLab`. Repo `TestingLab-iOS`, because a web TestingLab may follow as `TestingLab-Web`.

## Rules

- Everything is inside `#if DEBUG`; iOS-only code (the shake) also inside `os(iOS)`. Release builds contain nothing.
- No app-level types: apps add their tools through the `sections` builder and `BuildNote` actions.
- Native SwiftUI only, no design system: the lab looks like Settings. Red only for destructive rows.
- Swift 6, `defaultIsolation(MainActor.self)`; everything an app touches is `public` with an explicit `public init`.
- Tests are Swift Testing. `swift test` and `swiftlint --strict` pass before every commit.

## Releases

Tag `vX.Y.Z` on `main`; apps depend on `from: "X.0.0"`. Bump the minor for additions, the major for breaking API changes.
