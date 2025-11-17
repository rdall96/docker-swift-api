//
//  ContainersRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Fetch all containers.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerList
public struct DockerContainersRequest: DockerRequest {
    public typealias Body = Never
    public typealias Response = [Docker.Container]

    public struct Query: Encodable {
        let all: Bool
        let size: Bool = true // always return the size of the containers
    }

    public let endpoint: String = "containers/json"
    public let query: Query?

    private init(all: Bool) {
        query = .init(all: all)
    }

    public static var all: [Docker.Container] {
        get async throws {
            try await DockerContainersRequest(all: true).start()
        }
    }

    public static var running: [Docker.Container] {
        get async throws {
            try await DockerContainersRequest(all: false).start()
        }
    }

    public static func named(_ name: String) async throws -> Docker.Container? {
        // Docker container names are prefixed with `/` in the data model
        let containerName = name.trimmingPrefix("/")
        return try await all.first { $0.names.contains("/\(containerName)") }
    }
}
