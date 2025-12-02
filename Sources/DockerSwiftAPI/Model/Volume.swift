//
//  Volume.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker {
    public struct Volume: Equatable, Hashable, Identifiable, Decodable, Sendable {
        public typealias ID = String

        public enum Scope: String, Decodable, Sendable {
            case local
            case global
        }

        public struct Options: Equatable, Hashable, Codable, Sendable {
            public let device: String
            public let o: String
            public let type: String
        }

        /// The name of the volume.
        public let id: ID

        /// Name of the volume driver used by the volume.
        public let driver: String

        /// Mount path of the volume on the host.
        public let mountpoint: String

        private let createdAtString: String
        /// Date/Time the volume was created.
        /// Defaults to `distantPast` if the timestamp data is invalid.
        public var createdAt: Date {
            Helpers.date(from: createdAtString) ?? .distantPast
        }

        /// Low-level details about the volume, provided by the volume driver.
        /// This field is optional, and is omitted if the volume driver does not support this feature.
        public let status: [String : String]?

        /// User-defined key/value metadata.
        public let labels: Docker.Labels?

        /// The level at which the volume exists. Either `global` for cluster-wide, or `local` for machine level.
        public let scope: Scope

        /// The driver specific options used when creating the volume.
        public let options: Options?

        private enum CodingKeys: String, CodingKey {
            case id = "Name"
            case driver = "Driver"
            case mountpoint = "Mountpoint"
            case createdAtString = "CreatedAt"
            case status = "Status"
            case labels = "Labels"
            case scope = "Scope"
            case options = "Options"
        }
    }
}
