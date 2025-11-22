//
//  ContainersRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Fetch all containers.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerList
internal struct DockerContainersRequest: DockerRequest {
    typealias Body = Never
    typealias Response = [Docker.Container]

    struct Query: Encodable {
        let all: Bool
        let size: Bool = true // always return the size of the containers
    }

    let endpoint: String = "containers/json"
    let query: Query?

    init(all: Bool) {
        query = .init(all: all)
    }
}
