//
//  ContainerLogsRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/23/25.
//

import Foundation

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerLogs
internal struct ContainerLogsRequest: DockerRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let follow: Bool = false
        let stdout: Bool = true
        let stderr: Bool = true
        let since: UInt64?
        let until: UInt64?
        let timestamps: Bool
        let tail: String?
    }

    let endpoint: String
    let query: Query?

    init(containerID: Docker.Container.ID, query: Query) {
        endpoint = "/containers/\(containerID)/logs"
        self.query = query
    }

    // FIXME: Missing response
}
