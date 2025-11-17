//
//  Docker+TagImage.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

/// Tag a local Docker image.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageTag
public struct DockerTagImageRequest: DockerRequest {
    public typealias Body = Never
    public typealias Response = Void

    public struct Query: Encodable {
        let repo: String
        let tag: String
    }

    public let method: DockerRequest.Method = .POST
    public let endpoint: String
    public let query: Query?

    public init(imageID: String, newName: String, newTag: String) {
        endpoint = "/images/\(imageID)/tag"
        query = .init(
            repo: Self.sanitizeImageName(newName),
            tag: newTag
        )
    }
}

extension Docker.Image {
    /// Tag image.
    /// The tag defaults to `latest`.
    public func tag(name: String, tag: String = "latest") async throws {
        try await DockerTagImageRequest(imageID: self.id, newName: name, newTag: tag).start()
    }
}
