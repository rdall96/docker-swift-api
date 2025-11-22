//
//  RemoveImageRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

/// Remove a local Docker image.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageDelete
internal struct DockerRemoveImageRequest: DockerRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let force: Bool
        let noPrune: Bool

        private enum CodingKeys: String, CodingKey {
            case force
            case noPrune = "noprune"
        }
    }

    let method: DockerRequest.Method = .DELETE
    let endpoint: String
    let query: Query?

    init(imageID: String, force: Bool = false, prune: Bool = false) {
        endpoint = "/images/\(imageID)"
        query = .init(force: force, noPrune: !prune)
    }
}
