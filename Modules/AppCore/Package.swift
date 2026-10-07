// swift-tools-version: 6.2

import PackageDescription

let defaultIsolationSettings: [SwiftSetting] = [.defaultIsolation(MainActor.self)]

let package = Package(
    name: "AppCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "AppFeatures", targets: ["AppFeatures"]),
        .library(name: "AuthFeature", targets: ["AuthFeature"]),
        .library(name: "MovieListFeature", targets: ["MovieListFeature"]),
        .library(name: "MovieDetailFeature", targets: ["MovieDetailFeature"]),
        .library(name: "RecentlyViewedFeature", targets: ["RecentlyViewedFeature"]),
        .library(name: "SearchFeature", targets: ["SearchFeature"]),
        .library(name: "ListsFeature", targets: ["ListsFeature"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "RootFeature", targets: ["RootFeature"])
    ],
    dependencies: [
        .package(path: "../Networking")
    ],
    targets: [
        .target(
            name: "DesignSystem",
            resources: [.process("Resources/Localizable.xcstrings")],
            swiftSettings: defaultIsolationSettings
        ),
        .target(name: "Models", swiftSettings: defaultIsolationSettings),
        .target(
            name: "AppFeatures",
            dependencies: ["Models", "Networking"],
            resources: [.process("Resources/Localizable.xcstrings")],
            swiftSettings: defaultIsolationSettings
        ),
        .target(
            name: "AuthFeature",
            dependencies: ["Models", "DesignSystem", "AppFeatures"],
            resources: [.process("Resources/Localizable.xcstrings")],
            swiftSettings: defaultIsolationSettings
        ),
        .target(
            name: "MovieListFeature",
            dependencies: ["Models", "DesignSystem", "AppFeatures"],
            resources: [.process("Resources/Localizable.xcstrings")],
            swiftSettings: defaultIsolationSettings
        ),
        .target(
            name: "MovieDetailFeature",
            dependencies: ["Models", "DesignSystem", "AppFeatures"],
            resources: [.process("Resources/Localizable.xcstrings")],
            swiftSettings: defaultIsolationSettings
        ),
        .target(
            name: "RecentlyViewedFeature",
            dependencies: ["Models", "DesignSystem", "AppFeatures", "MovieListFeature"],
            resources: [.process("Resources/Localizable.xcstrings")],
            swiftSettings: defaultIsolationSettings
        ),
        .target(
            name: "SearchFeature",
            dependencies: ["Models", "DesignSystem", "AppFeatures", "MovieListFeature"],
            resources: [.process("Resources/Localizable.xcstrings")],
            swiftSettings: defaultIsolationSettings
        ),
        .target(
            name: "ListsFeature",
            dependencies: ["Models", "DesignSystem", "AppFeatures", "MovieListFeature", "MovieDetailFeature"],
            resources: [.process("Resources/Localizable.xcstrings")],
            swiftSettings: defaultIsolationSettings
        ),
        .target(
            name: "SettingsFeature",
            dependencies: ["Models", "DesignSystem", "AppFeatures"],
            resources: [.process("Resources/Localizable.xcstrings")],
            swiftSettings: defaultIsolationSettings
        ),
        .target(
            name: "RootFeature",
            dependencies: [
                "Models", "DesignSystem", "AppFeatures",
                "AuthFeature", "ListsFeature", "MovieDetailFeature", "MovieListFeature",
                "RecentlyViewedFeature", "SearchFeature", "SettingsFeature"
            ],
            resources: [.process("Resources/Localizable.xcstrings")],
            swiftSettings: defaultIsolationSettings
        ),

        .target(
            name: "TestSupport",
            dependencies: ["Models", "Networking", "AppFeatures"],
            path: "Tests/TestSupport",
            swiftSettings: defaultIsolationSettings
        ),
        .testTarget(
            name: "AppFeaturesTests",
            dependencies: ["AppFeatures", "Models", "Networking", "TestSupport"],
            swiftSettings: defaultIsolationSettings
        ),
        .testTarget(
            name: "AuthFeatureTests",
            dependencies: ["AuthFeature", "AppFeatures", "TestSupport"],
            swiftSettings: defaultIsolationSettings
        ),
        .testTarget(
            name: "SettingsFeatureTests",
            dependencies: ["SettingsFeature", "AppFeatures", "TestSupport"],
            swiftSettings: defaultIsolationSettings
        ),
        .testTarget(
            name: "MovieListFeatureTests",
            dependencies: ["MovieListFeature", "AppFeatures", "Models", "TestSupport"],
            swiftSettings: defaultIsolationSettings
        ),
        .testTarget(
            name: "MovieDetailFeatureTests",
            dependencies: ["MovieDetailFeature", "AppFeatures", "Models", "Networking", "TestSupport"],
            swiftSettings: defaultIsolationSettings
        ),
        .testTarget(
            name: "SearchFeatureTests",
            dependencies: ["SearchFeature", "AppFeatures", "Networking", "TestSupport"],
            swiftSettings: defaultIsolationSettings
        )
    ]
)
