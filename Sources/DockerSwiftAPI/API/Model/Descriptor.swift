//
//  Descriptor.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

extension Docker {
    public struct Descriptor: Equatable, Hashable, Decodable {
        public let digest: String
        public let sizeBytes: Int64
        public let urls: [URL]?
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
