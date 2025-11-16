//
//  DockerClient+TagImage.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation
import NIOHTTP1

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageTag
fileprivate struct TagImageRequest: DockerRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let repo: String
        let tag: String
    }

    let method: HTTPMethod = .POST
    let path: String
    let query: Query?

    init(imageID: String, newName: String, newTag: String) {
        self.path = "/images/\(imageID)/tag"
        query = .init(
            repo: Self.imageName(from: newName),
            tag: newTag
        )
    }
}

extension DockerClient {
    /// Tag an image.
    public func tagImage(with id: Docker.Image.ID, as name: String, tag: String = "latest") async throws(DockerError) {
        let request = TagImageRequest(imageID: id, newName: name, newTag: tag)
        try await run(request)
    }
}
