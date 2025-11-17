//
//  InspectVolumeRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Get info about a Docker volume.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Volume/operation/VolumeInspect
public struct DockerInspectVolumeRequest: DockerRequest {
    public typealias Query = Never
    public typealias Body = Never
    public typealias Response = Docker.Volume

    public let endpoint: String

    public init(volumeID: Docker.Volume.ID) {
        endpoint = "/volumes/\(volumeID)"
    }
}
