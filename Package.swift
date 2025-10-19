// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "postgres-migrations",
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17)],
    products: [
        .library(name: "PostgresMigrations", targets: ["PostgresMigrations"]),
        .plugin(name: "PostgresMigrationsBuildPlugin", targets: ["PostgresMigrationsBuildPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.25.0"),
        .package(url: "https://github.com/apple/swift-system.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
    ],
    targets: [
        .target(
            name: "PostgresMigrations",
            dependencies: [
                .product(name: "PostgresNIO", package: "postgres-nio")
            ]
        ),
        .plugin(
            name: "PostgresMigrationsBuildPlugin",
            capability: .buildTool(),
            dependencies: [
                "PostgresMigrationsBuildTool"
            ],
            path: "Plugins/PostgresMigrationsBuildPlugin"
        ),
        .executableTarget(
            name: "PostgresMigrationsBuildTool",
            dependencies: [
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Plugins/PostgresMigrationsBuildTool",
        ),
        .testTarget(
            name: "PostgresMigrationsTests",
            dependencies: [
                "PostgresMigrations"
            ]
        ),
    ]
)
