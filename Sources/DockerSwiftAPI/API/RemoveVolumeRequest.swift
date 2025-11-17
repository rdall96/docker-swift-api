//
//  RemoveVolumeRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

/// Remove a Docker volume.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Volume/operation/VolumeDelete
public struct DockerRemoveVolumeRequest: DockerRequest {
    public typealias Body = Never
    public typealias Response = Void

    public struct Query: Encodable {
        let force: Bool
    }

    public var method: DockerRequest.Method = .DELETE
    public let endpoint: String
    public let query: Query?

    public init(volumeID: Docker.Volume.ID, force: Bool = false) {
        endpoint = "/volumes/\(volumeID)"
        query = .init(force: force)
    }
}

extension Docker.Volume {
    /// Remove volume.
    public func remove(force: Bool = false) async throws {
        try await DockerRemoveVolumeRequest(volumeID: self.id, force: force).start()
    }
}
