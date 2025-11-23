//
//  DockerClient+Images.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/23/25.
//

import Foundation

extension DockerClient {

    // MARK: - Info

    /// List all local Docker images.
    public var images: [Docker.Image] {
        get async throws {
            try await run(FetchImagesRequest())
        }
    }

    /// List all images with the given name.
    public func images(name: String) async throws -> [Docker.Image] {
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

    // MARK: - Pull

    /// Pull an image by name and tag.
    @discardableResult
    public func pullImage(with tag: Docker.Image.Tag) async throws -> Docker.Image {
        let request = PullImageRequest(query: .init(
            image: tag.name,
            tag: tag.tag
        ))
        try await run(request)

        guard let image = try await image(tag: tag) else {
            logger.critical("Pulled image \(tag) successfully, but it doesn't exist on disk")
            throw DockerError.imageNotFound
        }
        return image
    }

    /// Pull an image by name and digest (id).
    public func pullImage(name: String, digest: String) async throws {
        let request = PullImageRequest(query: .init(
            image: Docker.Image.Tag.sanitizeImageName(name) + "@" + Docker.Image.Tag.sanitizeImageDigest(digest),
            tag: nil
        ))
        try await run(request)
    }

    // MARK: - Tag

    /// Tag an image.
    @discardableResult
    public func tag(_ image: Docker.Image, tag: Docker.Image.Tag) async throws -> Docker.Image {
        let request = TagImageRequest(imageID: image.id, newTag: tag)
        try await run(request)

        guard let image = try await self.image(tag: tag) else {
            logger.critical("Tagged image \(tag) successfully, but it doesn't exist on disk")
            throw DockerError.imageNotFound
        }
        return image
    }

    // MARK: - Remove

    /// Remove an image.
    /// - WARNING: This will remove any tags associated with this image ID.
    public func remove(_ image: Docker.Image, force: Bool = false, prune: Bool = false) async throws {
        let request = RemoveImageRequest(imageID: image.id, force: force, prune: prune)
        try await run(request)
    }

    // MARK: - Build

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
        let request = try BuildImageRequest(
            buildDirectoryURL: url,
            ignoreFiles: ignoreFiles,
            tag: tag,
            dockerFilePath: dockerFile,
            buildArgs: buildArgs,
            labels: labels,
            useCache: useCache,
            useBuildKit: useBuildKit
        )
        try await run(request)

        guard let image = try await image(tag: tag) else {
            logger.critical("Built image \(tag) successfully, but it doesn't exist on disk")
            throw DockerError.unknown
        }
        return image
    }

    // MARK: - Push

    /// Push an image to a remote registry.
    /// If there are multiple tags for this image, you can optionally specify which one should be pushed.
    /// If no tag is specified, all local tags for this image will be pushed automatically.
    /// See the `tags` property on `Docker.Image` for a list of available tags.
    public func push(_ image: Docker.Image, tag: Docker.Image.Tag? = nil) async throws {
        guard let authentication else {
            throw DockerError.notAuthenticated
        }
        let request = try PushImageRequest(image: image, tag: tag, auth: authentication)
        try await run(request)
    }
}
