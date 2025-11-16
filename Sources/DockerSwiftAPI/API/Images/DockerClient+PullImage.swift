//
//  DockerClient+PullImage.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation
import NIOHTTP1

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageCreate
fileprivate struct PullImageRequest: DockerRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let image: String
        let tag: String?

        private enum CodingKeys: String, CodingKey {
            case image = "fromImage"
            case tag
        }
    }

    let method: HTTPMethod = .POST
    let path: String = "/images/create"
    let query: Query?

    init(name: String, tag: String? = nil) {
        query = .init(
            image: Self.imageName(from: name),
            tag: tag
        )
    }

    init(name: String, digest: String) {
        let image = Self.imageName(from: name) + "@" + Self.imageDigest(from: digest)
        query = .init(image: image, tag: nil)
    }
}

extension DockerClient {
    /// Pull an image by name.
    public func pull(_ image: String, tag: String = "latest") async throws(DockerError) {
        let request = PullImageRequest(name: image, tag: tag)
        try await run(request)
    }

    /// Pull an image by digest.
    public func pull(_ image: String, digest: String) async throws(DockerError) {
        let request = PullImageRequest(name: image, digest: digest)
        try await run(request)
    }
}
