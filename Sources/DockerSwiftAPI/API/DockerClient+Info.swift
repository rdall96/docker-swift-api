//
//  DockerClient+Info.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/23/25.
//

import Foundation

extension DockerClient {

    /// Check if the Docker client is up and running.
    public var isAvailable: Bool {
        get async {
            do {
                try await run(PingRequest())
                return true
            }
            catch {
                return false
            }
        }
    }

    /// Get information about the Docker client.
    public var version: Docker.SystemVersion {
        get async throws {
            try await run(SystemVersionRequest())
        }
    }
}
