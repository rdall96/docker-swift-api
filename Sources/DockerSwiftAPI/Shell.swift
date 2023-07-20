//
//  Shell.swift
//  
//
//  Created by Ricky Dall'Armellina on 7/19/23.
//

import Foundation
import Commands

enum Shell {
    
    private static var env = Env()
    
    @discardableResult
    static func run(_ command: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let result = Commands.Bash.run(
                .init(command),
                environment: .global
            )
            if result.isFailure {
                continuation.resume(throwing: DockerError.systemError(command: command, output: result.errorOutput))
                return
            }
            continuation.resume(returning: result.output)
        }
    }
    
    static func curl<T:Decodable>(_ url: URL) async throws -> T {
        let output = try await Shell.run("curl \(url.absoluteString)")
        guard let data = output.data(using: .utf8) else {
            throw DockerError.invalidResponseFormat
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private static var dockerBin: String {
        get async throws {
            // if we already have the binary path, return that, otherwise search it
            if let binPath = env.dockerBin {
                return binPath
            }
            else {
                let out = try await Shell.run("find /usr/local /usr/bin -name docker")
                let options = out.split(separator: "\n")
                    .compactMap { String($0) }
                guard !options.isEmpty else {
                    throw DockerError.dockerNotFound
                }
                for option in options {
                    guard !option.contains("denied"),
                          !option.contains("permission"),
                          !option.contains(":")
                    else { continue }
                    let binPath = String(option.replacingOccurrences(of: " ", with: ""))
                    env.dockerBin = binPath
                    return binPath
                }
                throw DockerError.dockerNotFound
            }
        }
    }
    
    @discardableResult
    static func docker(_ command: String) async throws -> String {
        return try await Shell.run("\(try await dockerBin) \(command)")
    }
}

extension Shell {
    fileprivate struct Env {
        var dockerBin: String? = nil
    }
}
