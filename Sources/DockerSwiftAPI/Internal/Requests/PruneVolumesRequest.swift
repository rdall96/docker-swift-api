//
//  PruneVolumesRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/23/25.
//

import Foundation

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Volume/operation/VolumePrune
internal struct PruneVolumesRequest: DockerRequest {
    typealias Body = Never

    struct Query: Encodable {
        let all: Bool
    }

    let method: DockerRequestMethod = .POST
    let endpoint: String = "/volumes/prune"
//    let query: Query?

    struct Response: Decodable {
        let deleted: [Docker.Volume.ID]
        let reclaimedSpaceBytes: Int64

        private enum CodingKeys: String, CodingKey {
            case deleted = "VolumesDeleted"
            case reclaimedSpaceBytes = "SpaceReclaimed"
        }
    }
}
