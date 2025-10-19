//===----------------------------------------------------------------------===//
//
// This source file is part of the Hummingbird server framework project
//
// Copyright (c) 2024 the Hummingbird authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See hummingbird/CONTRIBUTORS.txt for the list of Hummingbird authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import ArgumentParser
import SystemPackage

@main
struct Build: ParsableCommand {
    @Option
    var target: String

    func run() throws {
        let targetFilename = FilePath(target)
        let fileDescriptor = try FileDescriptor.open(
            targetFilename,
            .readWrite,
            options: [.create, .truncate],
            permissions: [.ownerReadWrite, .groupRead, .otherRead]
        )
        _ = try fileDescriptor.closeAfter {
            do {
                let code = getMigrationCode()
                try code.utf8.withContiguousStorageIfAvailable { buffer in
                    _ = try fileDescriptor.write(.init(buffer))
                }
            } catch {
                print(error)
            }
        }
    }

    func getMigrationCode() -> String {
        """
        import Foundation
        import Logging
        import PostgresMigrations
        import PostgresNIO

        @main
        struct Migrate {
            static func getPostgresConfiguration() -> PostgresClient.Configuration? {
                guard let hostname = ProcessInfo.processInfo.environment["POSTGRES_HOSTNAME"],
                    let username = ProcessInfo.processInfo.environment["POSTGRES_USER"],
                    let password = ProcessInfo.processInfo.environment["POSTGRES_PASSWORD"],
                    let database = ProcessInfo.processInfo.environment["POSTGRES_DB"]
                else {
                    print("Migrate requires environment variables POSTGRES_HOSTNAME, POSTGRES_USER, POSTGRES_PASSWORD and POSTGRES_PASSWORD")
                    return nil
                }
                return PostgresClient.Configuration(
                    host: hostname,
                    port: ProcessInfo.processInfo.environment["POSTGRES_PORT"].flatMap { Int($0) } ?? 5432,
                    username: username,
                    password: password,
                    database: database,
                    tls: (ProcessInfo.processInfo.environment["POSTGRES_TLS"] != nil) ? .prefer(.clientDefault) : .disable
                )
            }

            static func runMigrations(_ migrations: DatabaseMigrations, revert: Bool, dryRun: Bool) async throws {
                let logger = Logger(label: "PostgresMigrations")
                guard let configuration = getPostgresConfiguration() else { exit(1) }
                let client = PostgresClient(
                    configuration: configuration,
                    backgroundLogger: logger
                )
                async let _ = client.run()
                try await Task.sleep(for: .milliseconds(200))
                if revert {
                    try await migrations.revert(client: client, logger: logger, dryRun: dryRun)
                }
                try await migrations.apply(client: client, logger: logger, dryRun: dryRun)
            }

            static func main() async throws {
                let dryRun = ProcessInfo.processInfo.arguments.contains("--dry-run")
                let revert = ProcessInfo.processInfo.arguments.contains("--revert")
                do {
                    try await runMigrations(migrations, revert: revert, dryRun: dryRun)
                } catch {
                    print("\\(error)")
                    exit(1)
                }
            }
        }
        """
    }
}
