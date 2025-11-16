//
//  DockerClient+PruneImages.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation
import NIOHTTP1

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImagePrune
fileprivate struct PruneImagesRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = Void

    let method: HTTPMethod = .POST
    let path: String = "/images/prune"
}

extension DockerClient {
    /// Remove unused images.
    public func pruneImages() async throws(DockerError) {
        try await run(PruneImagesRequest())
    }
}
