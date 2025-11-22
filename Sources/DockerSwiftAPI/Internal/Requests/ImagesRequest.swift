//
//  ImagesRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

/// Fetch all local Docker images.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageList
internal struct DockerImagesRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = [Docker.Image]

    let endpoint: String = "/images/json"
}
