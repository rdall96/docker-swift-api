//
//  ImagesRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

/// Fetch all local Docker images.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageList
public struct DockerImagesRequest: DockerRequest {
    public typealias Query = Never
    public typealias Body = Never
    public typealias Response = [Docker.Image]

    public let endpoint: String = "/images/json"

    private init() {}

    /// List all local Docker images.
    public static var all: [Docker.Image] {
        get async throws {
            try await DockerImagesRequest().start()
        }
    }

    /// List all images with the given name.
    public static func images(withName name: String) async throws -> [Docker.Image] {
        try await all.filter { image in
            image.tags.contains { tag in
                tag.name == name
            }
        }
    }

    /// Returns details about an image with the given ID, if it exists.
    public static func image(id: Docker.Image.ID) async throws -> Docker.Image? {
        try await all.first { $0.id == id }
    }

    /// Returns details an image with the given name and tag, if it exists.
    public static func image(tag: Docker.Image.Tag) async throws -> Docker.Image? {
        try await all.first { $0.tags.contains(tag) }
    }
}
