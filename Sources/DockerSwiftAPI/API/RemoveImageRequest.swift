//
//  RemoveImageRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

/// Remove a local Docker image.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageDelete
public struct DockerRemoveImageRequest: DockerRequest {
    public typealias Body = Never
    public typealias Response = Void

    public struct Query: Encodable {
        let force: Bool
        let noPrune: Bool

        private enum CodingKeys: String, CodingKey {
            case force
            case noPrune = "noprune"
        }
    }

    public let method: DockerRequest.Method = .DELETE
    public let endpoint: String
    public let query: Query?

    public init(imageID: String, force: Bool = false, prune: Bool = false) {
        endpoint = "/images/\(imageID)"
        query = .init(force: force, noPrune: !prune)
    }
}

extension Docker.Image {
    /// Remove image.
    public func remove(force: Bool = false, prune: Bool = false) async throws {
        try await DockerRemoveImageRequest(imageID: self.id, force: force, prune: prune).start()
    }
}
