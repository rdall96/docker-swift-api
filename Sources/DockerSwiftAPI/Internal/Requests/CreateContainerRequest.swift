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

    struct Metadata: Encodable {
        let name: String?
    }

    let method: DockerRequestMethod = .POST
    let endpoint: String = "/containers/create"
    let query: Metadata?
    let body: Config?

    struct Response: Decodable {
        let id: Docker.Container.ID

        private enum CodingKeys: String, CodingKey {
            case id = "Id"
        }
    }
}
