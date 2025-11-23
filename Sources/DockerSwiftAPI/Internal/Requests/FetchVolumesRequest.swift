//
//  FetchVolumesRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Fetch all local Docker volumes.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Volume/operation/VolumeList
internal struct FetchVolumesRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never

    let endpoint: String = "/volumes"

    struct Response: Decodable {
        let volumes: [Docker.Volume]
        let warnings: [String]?

        private enum CodingKeys: String, CodingKey {
            case volumes = "Volumes"
            case warnings = "Warnings"
        }
    }
}
