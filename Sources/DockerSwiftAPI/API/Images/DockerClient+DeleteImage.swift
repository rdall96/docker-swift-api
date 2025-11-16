//
//  DockerClient+DeleteImage.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation
import NIOHTTP1

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageDelete
fileprivate struct DeleteImageRequest: DockerRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let force: Bool
        let noPrune: Bool

        private enum CodingKeys: String, CodingKey {
            case force
            case noPrune = "noprune"
        }
    }

    let method: HTTPMethod = .DELETE
    let path: String
    let query: Query?

    init(imageID: String, force: Bool, noPrune: Bool) {
        path = "/images/\(imageID)"
        query = .init(force: force, noPrune: noPrune)
    }
}

extension DockerClient {
    /// Delete an image.
    public func deleteImage(with id: Docker.Image.ID, force: Bool = false, prune: Bool = true) async throws(DockerError) {
        let request = DeleteImageRequest(imageID: id, force: force, noPrune: !prune)
        try await run(request)
    }
}
