//
//  TagImageRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

/// Tag a local Docker image.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageTag
internal struct TagImageRequest: DockerRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let repo: String
        let tag: String
    }

    let method: DockerRequestMethod = .POST
    let endpoint: String
    let query: Query?

    init(imageID: String, newTag: Docker.Image.Tag) {
        endpoint = "/images/\(imageID)/tag"
        query = .init(repo: newTag.name, tag: newTag.tag)
    }
}
