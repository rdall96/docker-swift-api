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

    public init() {}

    /// List all images with the given name.
    public func images(withName name: String) async throws -> [Docker.Image] {
        try await start().filter { $0.tags.joined().contains(name) }
    }

    /// Returns details about an image with the given ID, if it exists.
    public func image(with id: Docker.Image.ID) async throws -> Docker.Image? {
        try await start().first { $0.id == id }
    }

    /// Returns details an image with the given name and tag, if it exists.
    public func image(withName name: String, tag: String = "latest") async throws -> Docker.Image? {
        try await start().first { $0.tags.contains("\(name):\(tag)") }
    }
}
