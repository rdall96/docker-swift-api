//
//  Platform.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker {
    /// Describes the platform which the image in the manifest runs on, as defined in the [OCI Image Index Specification](https://github.com/opencontainers/image-spec/blob/v1.0.1/image-index.md).
    public struct Platform: Equatable, Hashable, Decodable, Sendable {

        /// The CPU architecture, for example `amd64` or `x86`.
        public let architecture: Docker.Architecture

        /// The operating system, for example `linux` or `windows`.
        public let os: String

        /// Optional field specifying the operating system version, for example on Windows `10.0.19041.1165`.
        public let osVersion: String?

        /// Optional field specifying a variant of the CPU, for example `v7` to specify ARMv7 when architecture is **arm**.
        public let variant: String?

        private enum CodingKeys: String, CodingKey {
            case architecture
            case os
            case osVersion = "os.version"
            case variant
        }
    }
}
