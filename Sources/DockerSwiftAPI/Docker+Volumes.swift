//
//  Docker+Volumes.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/23/25.
//

import Foundation

extension Docker {

    // MARK: - Info

    /// List all local Docker volumes.
    public var volumes: [Docker.Volume] {
        get async throws {
            try await run(FetchVolumesRequest()).volumes
        }
    }

    /// Returns details about a volume with the given ID, if it exists.
    public func volume(id: Docker.Volume.ID) async throws -> Docker.Volume? {
        try await volumes.first { $0.id == id }
    }

    /// Get info about a Docker volume.
    public func inspectVolume(id: Docker.Volume.ID) async throws -> Docker.Volume {
        let request = InspectVolumeRequest(volumeID: id)
        return try await run(request)
    }

    // MARK: - Create

    /// Create a new volume.
    @discardableResult
    public func createVolume(
        id: String? = nil,
        driver: String = "local",
        options: Docker.Volume.Options? = nil,
        labels: Docker.Labels? = nil
    ) async throws -> Docker.Volume {
        let request = CreateVolumeRequest(body: .init(
            id: id,
            driver: driver,
            options: options,
            labels: labels
        ))
        return try await run(request)
    }

    // MARK: - Remove

    /// Remove a volume.
    public func remove(_ volume: Docker.Volume, force: Bool = false) async throws {
        let request = RemoveVolumeRequest(volumeID: volume.id, force: force)
        try await run(request)
    }

    /// Delete unused volumes.
    /// Returns a list of the deleted volume IDs.
    // FIXME: The prune request fails
//    public func pruneVolumes() async throws -> [Docker.Volume.ID] {
//        try await run(PruneVolumesRequest()).deleted
//    }
}
