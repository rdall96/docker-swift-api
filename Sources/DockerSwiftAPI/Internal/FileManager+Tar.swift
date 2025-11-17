//
//  FileManager+Tar.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

extension FileManager {
    func createTarGz(of source: URL, at destination: URL, excluding: [String]) throws {
        let sourceDirectoryPath = source.path
        let destinationFilePath = destination.path

        var arguments = ["-czf", "\(destinationFilePath)"]
        for excludePath in excluding {
            arguments.append("--exclude=\(excludePath)")
        }
        arguments.append("-C")
        arguments.append(sourceDirectoryPath)
        arguments.append(".")

        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["tar"] + arguments

        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            throw NSError(domain: "TarErrorDomain", code: Int(process.terminationStatus), userInfo: nil)
        }
    }
}
