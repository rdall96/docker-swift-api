//
//  ContainerProcessesRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// List processes running inside a container.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerTop
public struct DockerContainerProcessesRequest: DockerRequest {
    public typealias Query = Never
    public typealias Body = Never
    public typealias Response = DockerContainerProcessesResponse

    public let endpoint: String

    private init(id: Docker.Container.ID) {
        endpoint = "/containers/\(id)/top"
    }

    public static func processes(in containerID: Docker.Container.ID) async throws -> [Docker.Container.Process] {
        try await DockerContainerProcessesRequest(id: containerID).start().processes.compactMap {
            try Docker.Container.Process($0)
        }
    }
}

public struct DockerContainerProcessesResponse: Decodable {
    public let titles: [String]
    public let processes: [[String]]

    private enum CodingKeys: String, CodingKey {
        case titles = "Titles"
        case processes = "Processes"
    }
}
