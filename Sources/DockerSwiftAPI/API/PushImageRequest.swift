//
//  PushImageRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

/// Push a local image to a remote registry.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImagePush
public struct DockerPushImageRequest: DockerRequest {
    public typealias Body = Never
    public typealias Response = Void

    public struct Query: Encodable {}

    public let method: DockerRequest.Method = .POST
    public let endpoint: String
    public let query: Query?

//    public init(image: String, tag: String?) {
//        path = "/images/\(Self.imageName(from: image))/push"
//    }
}
