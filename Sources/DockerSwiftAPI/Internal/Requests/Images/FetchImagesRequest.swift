//
//  FetchImagesRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

/// Fetch all local Docker images.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageList
internal struct FetchImagesRequest: DockerRequest {
    typealias Body = Never
    typealias Response = [Docker.Image]

    struct Query: Encodable {
        let sharedSize: Bool = true
        let digests: Bool = true
        let manifests: Bool = true

        private enum CodingKeys: String, CodingKey {
            case sharedSize = "shared-size"
            case digests
            case manifests
        }
    }

    let endpoint: String = "images/json"
    let query: Query? = .init()
}
