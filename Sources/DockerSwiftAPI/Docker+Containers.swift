//
//  Docker+Containers.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/23/25.
//

import Foundation

extension Docker {

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
        // Ensure the container is running
        guard case .running = container.state else {
            throw DockerError.containerNotRunning
        }
        let request = ContainerProcessesRequest(id: container.id)
        return try await run(request).processes.compactMap {
            try Docker.Container.Process($0)
        }
    }

    /// Get stdout and stderr logs from a container.
    /// - NOTE: This endpoint works best when the container logging driver is set to `json-file` or `journald` and **tty** is enabled.
    public func logs(
        for container: Docker.Container,
        since: Date? = nil,
        until: Date? = nil,
        addTimestamps: Bool = false,
        tail: UInt? = nil
    ) async throws -> String {
        let request = ContainerLogsRequest(
            containerID: container.id,
            query: .init(
                since: since?.unixTimestamp,
                until: until?.unixTimestamp,
                timestamps: addTimestamps,
                tail: tail?.formatted()
            )
        )
        return try await run(request)
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

        let request = CreateContainerRequest(name: name, config: config)
        let id = try await run(request).id

        guard let container = try await containers(includeStopped: true).first(where: { $0.id == id }) else {
            logger.critical("Created container \(name ?? id), but it doesn't exist on disk")
            throw DockerError.containerNotFound
        }
        return container
    }

    /// Rename a container.
    public func renameContainer(_ container: Docker.Container, name: String) async throws {
        let request = RenameContainerRequest(containerID: container.id, name: name)
        try await run(request)
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

    // MARK: - Start/Stop/Restart/Kill

    /// Start a container.
    public func start(_ container: Docker.Container) async throws {
        let request = StartContainerRequest(containerID: container.id)
        do {
            try await run(request)
        }
        catch DockerError.ignoredRequest {
            // do nothing
        }
    }

    /// Stop a container.
    /// Optionally specify the stop signal to send to the container (i.e.: `SIGINT`) and how long to wait (in seconds) before the container is killed.
    public func stop(
        _ container: Docker.Container,
        signal: String? = nil,
        killAfter timeout: Int? = nil
    ) async throws {
        let request = StopContainerRequest(
            containerID: container.id,
            query: .init(signal: signal, timeout: timeout)
        )
        do {
            try await run(request)
        }
        catch DockerError.ignoredRequest {
            // do nothing
        }
    }

    /// Restart a container.
    /// Optionally specify the stop signal to send to the container (i.e.: `SIGINT`) and how long to wait (in seconds) before the container is killed.
    public func restart(
        _ container: Docker.Container,
        signal: String? = nil,
        killAfter timeout: Int? = nil
    ) async throws {
        let request = RestartContainerRequest(
            containerID: container.id,
            query: .init(signal: signal, timeout: timeout)
        )
        try await run(request)
    }

    /// Pause a container.
    public func pause(_ container: Docker.Container) async throws {
        let request = PauseContainerRequest(containerID: container.id)
        try await run(request)
    }

    /// Resume a container (unpause).
    public func resume(_ container: Docker.Container) async throws {
        let request = UnpauseContainerRequest(containerID: container.id)
        try await run(request)
    }

    /// Force stop (kill) a container.
    /// You can specify which signal to send when stopping the container (default: `SIGKILL`).
    public func kill(_ container: Docker.Container, signal: String = "SIGKILL") async throws {
        let request = KillContainerRequest(containerID: container.id, signal: signal)
        try await run(request)
    }

    /// Wait for a container to exist and return the exit code.
    public func wait(for container: Docker.Container) async throws -> Int64 {
        let request = ContainerWaitRequest(containerID: container.id)
        return try await run(request).statusCode
    }
}
