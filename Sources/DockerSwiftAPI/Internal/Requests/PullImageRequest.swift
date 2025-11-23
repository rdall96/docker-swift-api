//
//  PullImageRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

/// Pull a Docker image.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageCreate
internal struct PullImageRequest: DockerRequest {
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

    let method: DockerRequest.Method = .POST
    let endpoint: String = "/images/create"
    let query: Query?
}
