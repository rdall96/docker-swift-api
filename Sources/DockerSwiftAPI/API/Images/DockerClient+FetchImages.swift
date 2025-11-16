//
//  DockerClient+FetchImages.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation
import NIOHTTP1

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageList
fileprivate struct FetchImagesRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = [Docker.Image]

    let method: HTTPMethod = .GET
    let path: String = "/images/json"
}

extension DockerClient {
    /// List all images on the system.
    public var images: [Docker.Image] {
        get async throws(DockerError) {
            try await run(FetchImagesRequest())
        }
    }

    /// List all images with the given name.
    public func images(withName name: String) async throws(DockerError) -> [Docker.Image] {
        try await images.filter { $0.tags.joined().contains(name) }
    }

    /// Returns details about an image with the given ID, if it exists.
    public func image(with id: Docker.Image.ID) async throws(DockerError) -> Docker.Image? {
        try await images.first { $0.id == id }
    }

    /// Returns details an image with the given name and tag, if it exists.
    public func image(withName name: String, tag: String = "latest") async throws(DockerError) -> Docker.Image? {
        try await images.first { $0.tags.contains("\(name):\(tag)") }
    }
}
