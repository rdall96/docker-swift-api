//
//  CreateVolumeRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Create a new volume.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Volume/operation/VolumeCreate
internal struct DockerCreateVolumeRequest: DockerRequest {
    typealias Query = Never
    typealias Response = Docker.Volume

    struct Body: Encodable {
        let id: Docker.Volume.ID?
        let driver: String
        let options: Docker.Volume.Options?
        let labels: Docker.Labels?

        private enum CodingKeys: String, CodingKey {
            case id = "Name"
            case driver = "Driver"
            case options = "DriverOpts"
            case labels = "Labels"
        }
    }

    let method: DockerRequest.Method = .POST
    let endpoint: String = "volumes/create"
    let body: Body?
}
