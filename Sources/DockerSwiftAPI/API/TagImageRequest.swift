//
//  TagImageRequest.swift
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

    public init(imageID: String, newTag: Docker.Image.Tag) {
        endpoint = "/images/\(imageID)/tag"
        query = .init(repo: newTag.name, tag: newTag.tag)
    }
}

extension Docker.Image {
    /// Tag image.
    @discardableResult
    public func tag(_ newTag: Tag) async throws -> Docker.Image {
        try await DockerTagImageRequest(imageID: self.id, newTag: newTag).start()
        guard let newImage = try await DockerImagesRequest.image(tag: newTag) else {
            throw DockerError.imageNotFound
        }
        return newImage
    }
}
