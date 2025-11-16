//
//  DockerRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation
import NIOHTTP1

internal enum DockerRequestContentType: String {
    case json = "application/json"
    case tar = "application/x-tar"
}

internal protocol DockerRequest {
    associatedtype Query: Encodable
    associatedtype Body
    typealias ContentType = DockerRequestContentType
    associatedtype Response

    var method: HTTPMethod { get }
    var path: String { get }
    var query: Query? { get }
    var body: Body? { get }
    var contentType: ContentType { get }
}

extension DockerRequest {
    var query: Query? { nil }
    var body: Body? { nil }
    var contentType: ContentType { .json }
}

// MARK: - Helpers

extension DockerRequest {
    static func imageName(from name: String) -> String {
        name.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true).map(String.init).first ?? name
    }

    static func imageDigest(from digest: String) -> String {
        digest.hasPrefix("sha256:") ? digest : "sha256:\(digest)"
    }
}
