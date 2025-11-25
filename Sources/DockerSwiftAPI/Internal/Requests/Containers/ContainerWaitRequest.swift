//
//  ContainerWaitRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/23/25.
//

import Foundation

/// Block until a container stops, then returns the exit code.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerWait
internal struct ContainerWaitRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never

    let method: DockerRequestMethod = .POST
    let endpoint: String

    init(containerID: Docker.Container.ID) {
        endpoint = "containers/\(containerID)/wait"
    }

    struct Response: Decodable {
        struct WaitError: Decodable {
            let message: String

            private enum CodingKeys: String, CodingKey {
                case message = "Message"
            }
        }

        let statusCode: Int64
        let waitError: WaitError

        private enum CodingKeys: String, CodingKey {
            case statusCode = "StatusCode"
            case waitError = "Error"
        }
    }
}
