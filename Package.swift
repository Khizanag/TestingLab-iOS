// swift-tools-version: 6.2
import PackageDescription

let defaultSettings: [SwiftSetting] = [
    .defaultIsolation(MainActor.self),
]

let package = Package(
    name: "TestingLab",
    platforms: [
        .iOS(.v26),
        // Only so `swift test` runs on the Mac host; the lab itself is for iOS apps.
        .macOS(.v26),
    ],
    products: [
        .library(name: "TestingLab", targets: ["TestingLab"]),
    ],
    targets: [
        .target(
            name: "TestingLab",
            swiftSettings: defaultSettings,
        ),
        .testTarget(
            name: "TestingLabTests",
            dependencies: ["TestingLab"],
            swiftSettings: defaultSettings,
        ),
    ],
    swiftLanguageModes: [.v6],
)
