//
//  CreateContainerRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Create a new container.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerCreate
public struct DockerCreateContainerRequest: DockerRequest {
    public typealias Config = Docker.Container.Config

    public struct Metadata: Encodable {
        let name: String?
    }

    public struct Response: Decodable {
        let id: Docker.Container.ID

        private enum CodingKeys: String, CodingKey {
            case id = "Id"
        }
    }

    public let method: DockerRequest.Method = .POST
    public let endpoint: String = "/containers/create"
    public let query: Metadata?
    public let body: Config?

    private init(metadata: Metadata?, config: Config?) async throws {
        self.query = metadata
        self.body = config

        // Check if a container with this name already exists
        if let containerName = metadata?.name,
           try await DockerContainersRequest.named(containerName) != nil {
            logger.error("A container with the name \(containerName) already exists")
            throw DockerError.containerAlreadyExists
        }
    }

    @discardableResult
    public static func create(name: String? = nil, _ config: Config) async throws -> Docker.Container.ID {
        try await DockerCreateContainerRequest(
            metadata: .init(name: name),
            config: config
        ).start().id
    }
}
