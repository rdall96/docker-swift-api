//
//  InspectVolumeRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Get info about a Docker volume.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Volume/operation/VolumeInspect
internal struct InspectVolumeRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = Docker.Volume

    let endpoint: String

    init(volumeID: Docker.Volume.ID) {
        endpoint = "/volumes/\(volumeID)"
    }
}
