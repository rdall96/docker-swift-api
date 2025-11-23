//
//  DockerClient+Containers.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/23/25.
//

import Foundation

extension DockerClient {

    // MARK: - Info

    /// Fetch all containers.
    public func containers(includeStopped: Bool = true) async throws -> [Docker.Container] {
        let request = FetchContainersRequest(all: includeStopped)
        return try await run(request)
    }

    /// Fetch a contaier with the given name, if it exists.
    public func container(name: String) async throws -> Docker.Container? {
        // Docker container names are prefixed with `/` in the data model
        let containerName = name.trimmingPrefix("/")
        return try await containers(includeStopped: true).first {
            $0.names.contains("/\(containerName)")
        }
    }

    /// List processes running inside a container.
    public func processes(in container: Docker.Container) async throws -> [Docker.Container.Process] {
        let request = ContainerProcessesRequest(id: container.id)
        return try await run(request).processes.compactMap {
            try Docker.Container.Process($0)
        }
    }

    // MARK: - Create

    /// Create a new container with the given configuration.
    @discardableResult
    public func createContainer(
        name: String? = nil,
        config: Docker.Container.Config
    ) async throws -> Docker.Container {
        // Check if a container with this name already exists
        if let name, try await container(name: name) != nil {
            throw DockerError.containerAlreadyExists
        }

        let request = CreateContainerRequest(
            query: .init(name: name),
            body: config
        )
        let id = try await run(request).id

        guard let container = try await containers(includeStopped: true).first(where: { $0.id == id }) else {
            logger.critical("Created container \(name ?? id), but it doesn't exist on disk")
            throw DockerError.containerNotFound
        }
        return container
    }

    // MARK: - Remove

    /// Remove a container.
    public func remove(
        _ container: Docker.Container,
        force: Bool = false,
        pruneUnnamedVolumes: Bool = false
    ) async throws {
        let request = RemoveContainerRequest(
            containerID: container.id,
            removeUnusedVolumes: pruneUnnamedVolumes,
            force: force
        )
        try await run(request)
    }
}
