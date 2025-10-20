// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    // https://github.com/apple/swift-evolution/blob/main/proposals/0335-existential-any.md
    .enableUpcomingFeature("ExistentialAny"),

    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
    .enableUpcomingFeature("MemberImportVisibility"),

    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0409-access-level-on-imports.md
    .enableUpcomingFeature("InternalImportsByDefault"),
]

let package = Package(
    name: "postgres-migrations",
    platforms: [.macOS(.v14), .iOS(.v17), .macCatalyst(.v17), .tvOS(.v17), .visionOS(.v1)],
    products: [
        .library(name: "PostgresMigrations", targets: ["PostgresMigrations"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.25.0")
    ],
    targets: [
        .target(
            name: "PostgresMigrations",
            dependencies: [
                .product(name: "PostgresNIO", package: "postgres-nio")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "PostgresMigrationsTests",
            dependencies: [
                "PostgresMigrations"
            ],
            swiftSettings: swiftSettings
        ),
    ]
)
