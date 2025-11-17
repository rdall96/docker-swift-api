//
//  RemoveContainerRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Remove a Docker container.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerDelete
public struct DockerRemoveContainerRequest: DockerRequest {
    public typealias Body = Never
    public typealias Response = Void

    public struct Query: Encodable {
        let v: Bool
        let force: Bool
    }

    public let method: DockerRequest.Method = .DELETE
    public let endpoint: String
    public let query: Query?

    public init(containerID: Docker.Container.ID, removeUnusedVolumes: Bool = false, force: Bool = false) {
        endpoint = "/containers/\(containerID)"
        query = .init(v: removeUnusedVolumes, force: force)
    }
}

extension Docker.Container {
    public func remove(removeUnusedVolumes: Bool = false, force: Bool = false) async throws {
        try await DockerRemoveContainerRequest(
            containerID: self.id,
            removeUnusedVolumes: removeUnusedVolumes,
            force: force
        ).start()
    }
}
