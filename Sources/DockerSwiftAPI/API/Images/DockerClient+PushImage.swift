//
//  DockerClient+PushImage.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation
import NIOHTTP1

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImagePush
fileprivate struct PushImageRequest: DockerRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {}

    let method: HTTPMethod = .POST
    let path: String
    let query: Query?

//    init(image: String, tag: String?) {
//        path = "/images/\(Self.imageName(from: image))/push"
//    }
}

extension DockerClient {
    /// Push an image to a remote registry
    public func pushImage(_ image: Docker.Image) async throws(DockerError) {
        fatalError("Not implemented!")
    }
}
