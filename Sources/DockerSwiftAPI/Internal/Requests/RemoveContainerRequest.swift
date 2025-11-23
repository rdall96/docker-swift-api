//
//  RemoveContainerRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Remove a Docker container.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerDelete
internal struct RemoveContainerRequest: DockerRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let v: Bool
        let force: Bool
    }

    let method: DockerRequestMethod = .DELETE
    let endpoint: String
    let query: Query?

    init(containerID: Docker.Container.ID, removeUnusedVolumes: Bool = false, force: Bool = false) {
        endpoint = "/containers/\(containerID)"
        query = .init(v: removeUnusedVolumes, force: force)
    }
}
