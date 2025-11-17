//
//  VolumesRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Fetch all local Docker volumes.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Volume/operation/VolumeList
public struct DockerVolumesRequest: DockerRequest {
    public typealias Query = Never
    public typealias Body = Never
    public typealias Response = Docker.Volumes

    public let endpoint: String = "/volumes"

    private init() {}

    public static var all: [Docker.Volume] {
        get async throws {
            try await DockerVolumesRequest().start().volumes
        }
    }

    public static func volume(id: Docker.Volume.ID) async throws -> Docker.Volume? {
        try await all.first { $0.id == id }
    }
}

extension Docker {
    public struct Volumes: Decodable {
        public let volumes: [Volume]
        public let warnings: [String]?

        private enum CodingKeys: String, CodingKey {
            case volumes = "Volumes"
            case warnings = "Warnings"
        }
    }
}
