//
//  Image.swift
//  
//
//  Created by Ricky Dall'Armellina on 7/19/23.
//

import Foundation

extension Docker {

    /// A Docker image.
    public struct Image: Equatable, Hashable, Identifiable, Decodable {
        public typealias ID = String

        public let id: ID
        public let parentID: ID?
        public let tags: [String]
        public let digests: [String]
        public let createdAt: Date
        public let sizeBytes: Int64
        public let labels: Docker.Labels?
        public let containers: Int64

        private enum CodingKeys: String, CodingKey {
            case id = "Id"
            case parentID = "ParentId"
            case tags = "RepoTags"
            case digests = "RepoDigests"
            case createdAt = "Created"
            case sizeBytes = "Size"
            case labels = "Labels"
            case containers = "Containers"
        }
    }
}

extension Docker.Image: CustomStringConvertible {
    public var description: String {
        "[\(id)] \(tags.joined(separator: ", "))"
    }
}
