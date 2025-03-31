// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "postgres-migrations",
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17)],
    products: [
        .library(name: "PostgresMigrations", targets: ["PostgresMigrations"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/postgres-nio", from: "1.25.0")
    ],
    targets: [
        .target(
            name: "PostgresMigrations",
            dependencies: [
                .product(name: "PostgresNIO", package: "postgres-nio")
            ]
        ),
        .testTarget(
            name: "PostgresMigrationsTests",
            dependencies: [
                "PostgresMigrations"
            ]
        ),
    ],
    swiftLanguageVersions: [.v5, .version("6")]
)
