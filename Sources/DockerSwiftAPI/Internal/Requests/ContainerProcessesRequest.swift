//
//  ContainerProcessesRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// List processes running inside a container.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerTop
internal struct ContainerProcessesRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never

    let endpoint: String

    init(id: Docker.Container.ID) {
        endpoint = "/containers/\(id)/top"
    }

    struct Response: Decodable {
        let titles: [String]
        let processes: [[String]]

        private enum CodingKeys: String, CodingKey {
            case titles = "Titles"
            case processes = "Processes"
        }
    }
}
