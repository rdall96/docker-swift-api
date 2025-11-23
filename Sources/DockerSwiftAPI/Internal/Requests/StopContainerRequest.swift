//
//  StopContainerRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/23/25.
//

import Foundation

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerStop
internal struct StopContainerRequest: DockerRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let signal: String?
        let timeout: Int?
    }

    let method: DockerRequestMethod = .POST
    let endpoint: String
    let query: Query?

    init(containerID: Docker.Container.ID, query: Query?) {
        endpoint = "/containers/\(containerID)/stop"
        self.query = query
    }
}
