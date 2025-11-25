//
//  PauseContainerRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/23/25.
//

import Foundation

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerPause
internal struct PauseContainerRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = Void

    let method: DockerRequestMethod = .POST
    let endpoint: String

    init(containerID: Docker.Container.ID) {
        endpoint = "containers/\(containerID)/pause"
    }
}
