//
//  Descriptor.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

extension Docker {
    public struct Descriptor: Equatable, Hashable, Decodable {

        public struct Platform: Equatable, Hashable, Decodable {

            public let architecture: String
            public let os: String
            public let osVersion: String
            public let variant: String

            private enum CodingKeys: String, CodingKey {
                case architecture
                case os
                case osVersion = "os.version"
                case variant
            }
        }

        public let digest: String
        public let sizeBytes: Int64
        public let urls: [URL]?
        public let annotations: [String : String]?
        public let platform: Platform?

        private enum CodingKeys: String, CodingKey {
            case digest
            case sizeBytes = "size"
            case urls
            case annotations
            case platform
        }
    }
}
