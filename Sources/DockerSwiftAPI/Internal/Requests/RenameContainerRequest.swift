//
//  RenameContainerRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/23/25.
//

import Foundation

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerRename
internal struct RenameContainerRequest: DockerRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let name: String
    }

    let method: DockerRequestMethod = .POST
    let endpoint: String
    let query: Query?

    init(containerID: Docker.Container.ID, name: String) {
        endpoint = "/containers/\(containerID)/rename"
        query = .init(name: name)
    }
}
