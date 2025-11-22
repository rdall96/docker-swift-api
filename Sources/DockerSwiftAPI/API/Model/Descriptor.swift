//
//  Descriptor.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

extension Docker {
    /// A descriptor struct containing digest, media type, and size, as defined in the [OCI Content Descriptors Specification](https://github.com/opencontainers/image-spec/blob/v1.0.1/image-index.md).
    public struct Descriptor: Equatable, Hashable, Decodable, Sendable {

        /// The digest of the targeted content.
        public let digest: String

        /// The size in bytes of the blob.
        public let sizeBytes: Int64

        /// List of URLs from which this object MAY be downloaded.
        public let urls: [URL]?

        /// Arbitrary metadata relating to the targeted content.
        public let annotations: [String : String]?
        
        public let platform: Docker.Platform?

        private enum CodingKeys: String, CodingKey {
            case digest
            case sizeBytes = "size"
            case urls
            case annotations
            case platform
        }
    }
}
