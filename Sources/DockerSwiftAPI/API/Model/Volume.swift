//
//  Volume.swift
//  
//
//  Created by Ricky Dall'Armellina on 8/18/23.
//

import Foundation

extension Docker {
    public struct Volume: Equatable, Hashable, Identifiable, Decodable {
        public typealias ID = String

        public enum Scope: String, Decodable {
            case local
            case global
        }

        public struct Options: Equatable, Hashable, Codable {
            public let device: String
            public let o: String
            public let type: String
        }

        public struct UsageData: Equatable, Hashable, Decodable {
            public let size: Int64
            public let refCount: Int64

            private enum CodingKeys: String, CodingKey {
                case size = "Size"
                case refCount = "RefCount"
            }
        }

        /// The name of the volume.
        public let id: ID
        public let driver: String
        public let mountpoint: String
        private let createdAtString: String
        public let status: [String : String]?
        public let labels: Docker.Labels?
        public let scope: Scope
        public let options: Options?
        public let usageData: UsageData?

        public var createdAt: Date {
            Helpers.date(from: createdAtString) ?? .distantPast
        }

        private enum CodingKeys: String, CodingKey {
            case id = "Name"
            case driver = "Driver"
            case mountpoint = "Mountpoint"
            case createdAtString = "CreatedAt"
            case status = "Status"
            case labels = "Labels"
            case scope = "Scope"
            case options = "Options"
            case usageData = "UsageData"
        }
    }
}
