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
    public init(image: String, tag: String?, auth: DockerAuthenticationContext) {
        endpoint = "/images/\(Self.sanitizeImageName(image))/push"
        query = .init(tag: tag)
        authContext = auth
    }
}

extension Docker.Image {
    /// Push this image to a remote registry.
    /// If there are multiple tags for this image, you can optionally specify which one should be pushed.
    /// If no tags are specified all local tags for this image will be pushed automatically.
    /// See the `tags` property on `Docker.Image` for a list of available tags.
    public func push(tag: String? = nil, auth: DockerAuthenticationContext) async throws {
        var pushRequests: [DockerPushImageRequest] = []
        if let tag {
            pushRequests.append(.init(image: id, tag: tag, auth: auth))
        }
        else {
            pushRequests.append(contentsOf: self.namesAndTags.compactMap {
                .init(image: $0.name, tag: $0.tag, auth: auth)
            })
        }

        try await withThrowingTaskGroup { group in
            pushRequests.forEach { request in
                group.addTask {
                    try await request.start()
                }
            }

            try await group.waitForAll()
        }
    }
}
