//
//  PushImageRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

/// Push a local image to a remote registry.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImagePush
internal struct PushImageRequest: DockerRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let tag: String?
    }

    let method: DockerRequestMethod = .POST
    let endpoint: String
    let query: Query?
    let authContext: DockerAuthenticationContext?

    /// Push an image to a remote registry.
    /// If you don't specify a tag for the image, all local tags will be pushed.
    init(image: Docker.Image, tag: Docker.Image.Tag?, auth: DockerAuthenticationContext) throws {
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
