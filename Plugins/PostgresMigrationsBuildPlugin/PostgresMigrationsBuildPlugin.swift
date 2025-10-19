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

import Foundation
import PackagePlugin

@main
struct PostgresMigrationsBuildPlugin: BuildToolPlugin {
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        let tool = try context.tool(named: "PostgresMigrationsBuildTool")
        guard let target = target as? SwiftSourceModuleTarget else { return [] }
        guard target.kind == .executable else { return [] }

        let targetFile = context.pluginWorkDirectoryURL.appending(path: "_migrate.swift")
        let commandArgs: [String] = [
            "--target", targetFile.path(percentEncoded: false),
        ]
        let outputFiles: [URL] = [
            targetFile
        ]

        let command: Command = .buildCommand(
            displayName: "Generating migration support files",
            executable: tool.url,
            arguments: commandArgs,
            outputFiles: outputFiles
        )

        return [command]
    }
}
