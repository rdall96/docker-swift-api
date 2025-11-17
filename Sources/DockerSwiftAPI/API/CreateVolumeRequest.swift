//
//  CreateVolumeRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Create a new volume.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Volume/operation/VolumeCreate
public struct DockerCreateVolumeRequest: DockerRequest {
    public typealias Query = Never
    public typealias Response = Docker.Volume

    public struct Body: Encodable {
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

    public let method: DockerRequest.Method = .POST
    public let endpoint: String = "volumes/create"
    public let body: Body?

    public init(
        id: Docker.Volume.ID? = nil,
        driver: String = "local",
        options: Docker.Volume.Options? = nil,
        labels: Docker.Labels? = nil
    ) {
        body = .init(id: id, driver: driver, options: options, labels: labels)
    }
}
