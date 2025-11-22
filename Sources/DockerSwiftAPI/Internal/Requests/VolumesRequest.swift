//
//  VolumesRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Fetch all local Docker volumes.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Volume/operation/VolumeList
internal struct DockerVolumesRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = Docker.Volumes

    let endpoint: String = "/volumes"
}

extension Docker {
    struct Volumes: Decodable {
        let volumes: [Volume]
        let warnings: [String]?

        private enum CodingKeys: String, CodingKey {
            case volumes = "Volumes"
            case warnings = "Warnings"
        }
    }
}
