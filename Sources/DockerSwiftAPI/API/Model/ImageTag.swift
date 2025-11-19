//
//  ImageTag.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/19/25.
//

import Foundation

extension Docker.Image {
    /// A tag for a Docker image.
    public struct Tag: Hashable {

        /// The name of the image.
        public let name: String

        /// The tag for the image.
        public let tag: String

        /// Create a new image tag.
        /// If the **tag** is not specified, it defaults to `latest`.
        public init(name: String, tag: String = "latest") {
            self.name = Self.sanitizeImageName(name)
            self.tag = tag
        }

        internal init?(_ string: String) {
            let components = string.split(separator: ":", maxSplits: 1).map(String.init)
            guard components.count == 2 else {
                return nil
            }
            self.init(name: components[0], tag: components[1])
        }
    }
}

extension Docker.Image.Tag: CustomStringConvertible {
    public var description: String { "\(name):\(tag)" }
}

internal extension Docker.Image.Tag {
    static func sanitizeImageName(_ name: String) -> String {
        name.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true).map(String.init).first ?? name
    }

    static func sanitizeImageDigest(_ digest: String) -> String {
        digest.hasPrefix("sha256:") ? digest : "sha256:\(digest)"
    }
}
