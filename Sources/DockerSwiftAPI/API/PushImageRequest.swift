//
//  PushImageRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

/// Push a local image to a remote registry.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImagePush
public struct DockerPushImageRequest: DockerRequest {
    public typealias Body = Never
    public typealias Response = Void

    public struct Query: Encodable {
        let tag: String?
    }

    public let method: DockerRequest.Method = .POST
    public let endpoint: String
    public let query: Query?
    public let authContext: DockerAuthenticationContext?

    /// Push an image to a remote registry.
    /// If you don't specify a tag for the image, all local tags will be pushed.
    public init(image: Docker.Image, tag: Docker.Image.Tag?, auth: DockerAuthenticationContext) throws {
        // ensure the image has at least one valid tag
        if image.tags.isEmpty {
            throw DockerError.invalidTag
        }
        // ensure the requested tag exists for this image
        if let tag, !image.tags.contains(tag) {
            throw DockerError.invalidTag
        }

        // we already validated that the image has at least one tag, so this should never fail
        guard let imageName = tag?.name ?? image.tags.first?.name else {
            throw DockerError.unknown
        }

        endpoint = "/images/\(imageName)/push"
        query = .init(tag: tag?.tag)
        authContext = auth
    }
}

extension Docker.Image {
    /// Push this image to a remote registry.
    /// If there are multiple tags for this image, you can optionally specify which one should be pushed.
    /// If no tags are specified all local tags for this image will be pushed automatically.
    /// See the `tags` property on `Docker.Image` for a list of available tags.
    public func push(tag: Tag? = nil, auth: DockerAuthenticationContext) async throws {
        try await DockerPushImageRequest(image: self, tag: tag, auth: auth).start()
    }
}
