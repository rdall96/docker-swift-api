//
//  CreateContainerRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Create a new container.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerCreate
internal struct DockerCreateContainerRequest: DockerRequest {
    typealias Config = Docker.Container.Config

    struct Metadata: Encodable {
        let name: String?
    }

    struct Response: Decodable {
        let id: Docker.Container.ID

        private enum CodingKeys: String, CodingKey {
            case id = "Id"
        }
    }

    let method: DockerRequest.Method = .POST
    let endpoint: String = "/containers/create"
    let query: Metadata?
    let body: Config?

    init(metadata: Metadata?, config: Config?) {
        self.query = metadata
        self.body = config
    }
}
