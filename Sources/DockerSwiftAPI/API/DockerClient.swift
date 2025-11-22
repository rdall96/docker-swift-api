//
//  DockerClient.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/22/25.
//

import Foundation
import Logging

public final class DockerClient {
    public typealias RequestTimeout = Int64

    /// The connection used for communicating with Docker.
    public let connection: DockerConnection

    /// Authentication information for communicating with remote registries.
    public var authentication: DockerAuthenticationContext?

    /// Request timeout in seconds.
    public var timeout: RequestTimeout? = nil

    public var logger: Logger

    /// Create a new Docker client to send requests to.
    /// By default it uses the local socket connection (see: `DockerConnection.defaultSocket`).
    public init(
        connection: DockerConnection = .defaultSocket,
        timeout: RequestTimeout? = nil,
        logger: Logger? = nil
    ) {
        self.connection = connection
        self.timeout = timeout
        self.logger = logger ?? Logger(label: "docker-\(connection.description)")
    }

    private var runner: DockerRunner {
        connection.runner(logger: logger)
    }

    public var isAvailable: Bool {
        get async {
            do {
                try await runner.run(DockerPingRequest(), timeout: timeout)
                return true
            }
            catch {
                return false
            }
        }
    }

    public var version: Docker.SystemVersion {
        get async throws {
            try await runner.run(DockerVersionRequest(), timeout: timeout)
        }
    }

    // MARK: - Images

    /// List all local Docker images.
    public var images: [Docker.Image] {
        get async throws {
            let request = DockerImagesRequest()
            return try await runner.run(request, timeout: timeout)
        }
    }

    /// List all images with the given name.
    public func images(withName name: String) async throws -> [Docker.Image] {
        try await images.filter { image in
            image.tags.contains { tag in
                tag.name == name
            }
        }
    }

    /// Returns details about an image with the given ID, if it exists.
    public func image(id: Docker.Image.ID) async throws -> Docker.Image? {
        try await images.first { $0.id == id }
    }

    /// Returns details an image with the given name and tag, if it exists.
    public func image(tag: Docker.Image.Tag) async throws -> Docker.Image? {
        try await images.first { $0.tags.contains(tag) }
    }

    /// Pull an image by name and tag.
    @discardableResult
    public func pullImage(with tag: Docker.Image.Tag) async throws -> Docker.Image {
        let request = DockerPullImageRequest(query: .init(
            image: tag.name,
            tag: tag.tag
        ))
        try await runner.run(request, timeout: timeout)

        guard let image = try await image(tag: tag) else {
            logger.critical("Pulled image \(tag) successfully, but it doesn't exist on disk")
            throw DockerError.imageNotFound
        }
        return image
    }

    /// Pull an image by name and digest (id).
    public func pullImage(name: String, digest: String) async throws {
        let request = DockerPullImageRequest(query: .init(
            image: Docker.Image.Tag.sanitizeImageName(name) + "@" + Docker.Image.Tag.sanitizeImageDigest(digest),
            tag: nil
        ))
        try await runner.run(request, timeout: timeout)
    }

    /// Tag an image.
    @discardableResult
    public func tag(image: Docker.Image, _ tag: Docker.Image.Tag) async throws -> Docker.Image {
        let request = DockerTagImageRequest(imageID: image.id, newTag: tag)
        try await runner.run(request, timeout: timeout)

        guard let image = try await self.image(tag: tag) else {
            logger.critical("Tagged image \(tag) successfully, but it doesn't exist on disk")
            throw DockerError.imageNotFound
        }
        return image
    }

    /// Remove an image.
    /// - WARNING: This will remove any tags associated with this image ID.
    public func remove(_ image: Docker.Image, force: Bool = false, prune: Bool = false) async throws {
        try await runner.run(
            DockerRemoveImageRequest(imageID: image.id, force: force, prune: prune),
            timeout: timeout
        )
    }

    /// Build a new image from the given context.
    public func buildImage(
        at url: URL,
        ignoreFiles: [String] = [],
        tag: Docker.Image.Tag,
        dockerFile: String = "Dockerfile",
        buildArgs: Docker.BuildArgs? = nil,
        labels: Docker.Labels? = nil,
        useCache: Bool = true,
        useBuildKit: Bool = false
    ) async throws -> Docker.Image {
        let request = try DockerBuildRequest(
            buildDirectoryURL: url,
            ignoreFiles: ignoreFiles,
            tag: tag,
            dockerFilePath: dockerFile,
            buildArgs: buildArgs,
            labels: labels,
            useCache: useCache,
            useBuildKit: useBuildKit
        )
        try await runner.run(request, timeout: timeout)

        guard let image = try await image(tag: tag) else {
            logger.critical("Built image \(tag) successfully, but it doesn't exist on disk")
            throw DockerError.unknown
        }
        return image
    }

    /// Push an image to a remote registry.
    /// If there are multiple tags for this image, you can optionally specify which one should be pushed.
    /// If no tag is specified, all local tags for this image will be pushed automatically.
    /// See the `tags` property on `Docker.Image` for a list of available tags.
    public func push(_ image: Docker.Image, tag: Docker.Image.Tag? = nil) async throws {
        guard let authentication else {
            throw DockerError.notAuthenticated
        }
        try await runner.run(
            DockerPushImageRequest(image: image, tag: tag, auth: authentication),
            timeout: timeout
        )
    }

    // MARK: - Volumes

    /// List all local Docker volumes.
    public var volumes: [Docker.Volume] {
        get async throws {
            try await runner.run(DockerVolumesRequest(), timeout: timeout).volumes
        }
    }

    /// Returns details about a volume with the given ID, if it exists.
    public func volume(id: Docker.Volume.ID) async throws -> Docker.Volume? {
        try await volumes.first { $0.id == id }
    }

    /// Get info about a Docker volume.
    public func inspectVolume(id: Docker.Volume.ID) async throws -> Docker.Volume {
        try await runner.run(DockerInspectVolumeRequest(volumeID: id), timeout: timeout)
    }

    /// Create a new volume.
    @discardableResult
    public func createVolume(
        id: String? = nil,
        driver: String = "local",
        options: Docker.Volume.Options? = nil,
        labels: Docker.Labels? = nil
    ) async throws -> Docker.Volume {
        let request = DockerCreateVolumeRequest(body: .init(
            id: id,
            driver: driver,
            options: options,
            labels: labels
        ))
        return try await runner.run(request, timeout: timeout)
    }

    /// Remove a volume.
    public func remove(_ volume: Docker.Volume, force: Bool = false) async throws {
        try await runner.run(
            DockerRemoveVolumeRequest(volumeID: volume.id, force: force),
            timeout: timeout
        )
    }

    // MARK: - Containers

    /// Fetch all containers.
    public func containers(includeStopped: Bool = true) async throws -> [Docker.Container] {
        try await runner.run(
            DockerContainersRequest(all: includeStopped),
            timeout: timeout
        )
    }

    /// Fetch a contaier with the given name, if it exists.
    public func container(named name: String) async throws -> Docker.Container? {
        // Docker container names are prefixed with `/` in the data model
        let containerName = name.trimmingPrefix("/")
        return try await containers(includeStopped: true).first {
            $0.names.contains("/\(containerName)")
        }
    }

    /// List processes running inside a container.
    public func processes(in container: Docker.Container) async throws -> [Docker.Container.Process] {
        try await runner.run(
            DockerContainerProcessesRequest(id: container.id),
            timeout: timeout
        ).processes.compactMap { try Docker.Container.Process($0) }
    }

    /// Create a new container with the given configuration.
    @discardableResult
    public func createContainer(
        name: String? = nil,
        _ config: Docker.Container.Config
    ) async throws -> Docker.Container {
        // Check if a container with this name already exists
        if let name, try await container(named: name) != nil {
            throw DockerError.containerAlreadyExists
        }

        let request = DockerCreateContainerRequest(
            metadata: .init(name: name),
            config: config
        )
        let id = try await runner.run(request, timeout: timeout).id

        guard let container = try await containers(includeStopped: true).first(where: { $0.id == id }) else {
            logger.critical("Created container \(name ?? id), but it doesn't exist on disk")
            throw DockerError.containerNotFound
        }
        return container
    }

    /// Remove a container.
    public func remove(
        _ container: Docker.Container,
        force: Bool = false,
        pruneUnnamedVolumes: Bool = false
    ) async throws {
        try await runner.run(
            DockerRemoveContainerRequest(containerID: container.id, removeUnusedVolumes: pruneUnnamedVolumes, force: force),
            timeout: timeout
        )
    }
}

extension DockerClient: CustomStringConvertible {
    public var description: String {
        "Docker \(connection.description)"
    }
}
