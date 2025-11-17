//
//  PullImageRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

/// Pull a Docker image.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageCreate
public struct DockerPullImageRequest: DockerRequest {
    public typealias Body = Never
    public typealias Response = Void

    public struct Query: Encodable {
        let image: String
        let tag: String?

        private enum CodingKeys: String, CodingKey {
            case image = "fromImage"
            case tag
        }
    }

    public let method: DockerRequest.Method = .POST
    public let endpoint: String = "/images/create"
    public let query: Query?

    /// Pull an image by name and tag.
    /// Tag defaults to `latest`.
    public init(name: String, tag: String? = nil) {
        query = .init(
            image: Self.sanitizeImageName(name),
            tag: tag
        )
    }

    /// Pull an image by name and digest (id).
    public init(name: String, digest: String) {
        let image = Self.sanitizeImageName(name) + "@" + Self.sanitizeImageDigest(digest)
        query = .init(image: image, tag: nil)
    }
}
