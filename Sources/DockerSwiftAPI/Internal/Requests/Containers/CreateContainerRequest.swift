//
//  CreateContainerRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Create a new container.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerCreate
internal struct CreateContainerRequest: DockerRequest {
    typealias Config = Docker.Container.Config

    struct Query: Encodable {
        let name: String?
    }

    let method: DockerRequestMethod = .POST
    let endpoint: String = "containers/create"
    let query: Query?
    let body: Config?

    init(name: String? = nil, config: Config) {
        query = .init(name: name ?? "") // default to an empty string if no name, Docker will automatically assign a name
        body = config
    }

    struct Response: Decodable {
        let id: Docker.Container.ID

        private enum CodingKeys: String, CodingKey {
            case id = "Id"
        }
    }
}
