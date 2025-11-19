//
//  Image.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker {

    /// A Docker image.
    public struct Image: Equatable, Hashable, Identifiable, Decodable {
        public typealias ID = String

        /// ID is the content-addressable ID of an image.
        ///
        /// This identifier is a content-addressable digest calculated from the image's configuration (which includes the digests of layers used by the image).
        ///
        /// - NOTE:This digest differs from the `digests`, which holds digests of image manifests that reference the image.
        public let id: ID

        /// ID of the parent image.
        ///
        /// Depending on how the image was created, this field may be empty and is only set for images that were built/created locally.
        ///
        /// - NOTE: This field is empty if the image was pulled from an image registry.
        public let parentID: ID?

        /// List of image names/tags in the local image cache that reference this image.
        ///
        /// Multiple image tags can refer to the same image, and this list may be empty if no tags reference the image, in which case the image is "untagged",
        /// in which case it can still be referenced by its `id`.
        public let tags: [Tag]

        /// List of content-addressable digests of locally available image manifests that the image is referenced from. Multiple manifests can refer to the same image.
        ///
        /// These digests are usually only available if the image was either pulled from a registry, or if the image was pushed to a registry,
        /// which is when the manifest is generated and its digest calculated.
        public let digests: [String]

        /// Date and time at which the image was created.
        public let createdAt: Date

        /// Total size of the image including all layers it is composed of.
        public let sizeBytes: Int64

        /// User-defined key/value metadata.
        public let labels: Docker.Labels?

        /// Number of containers using this image. Includes both stopped and running containers.
        ///
        /// `-1` indicates that the value has not been set / calculated.
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

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(ID.self, forKey: .id)
            self.parentID = try container.decodeIfPresent(ID.self, forKey: .parentID)
            self.tags = try container.decode([String].self, forKey: .tags).compactMap(Tag.init(_:))
            self.digests = try container.decode([String].self, forKey: .digests)
            self.createdAt = try container.decode(Date.self, forKey: .createdAt)
            self.sizeBytes = try container.decode(Int64.self, forKey: .sizeBytes)
            self.labels = try container.decodeIfPresent(Docker.Labels.self, forKey: .labels)
            self.containers = try container.decode(Int64.self, forKey: .containers)
        }
    }
}

extension Docker.Image: CustomStringConvertible {
    public var description: String {
        "[\(id)] \(tags.map(\.description).joined(separator: ", "))"
    }
}
