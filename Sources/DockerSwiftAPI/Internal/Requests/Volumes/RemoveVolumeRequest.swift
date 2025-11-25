//
//  RemoveVolumeRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Remove a Docker volume.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Volume/operation/VolumeDelete
internal struct RemoveVolumeRequest: DockerRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let force: Bool
    }

    let method: DockerRequestMethod = .DELETE
    let endpoint: String
    let query: Query?

    init(volumeID: Docker.Volume.ID, force: Bool = false) {
        endpoint = "volumes/\(volumeID)"
        query = .init(force: force)
    }
}
