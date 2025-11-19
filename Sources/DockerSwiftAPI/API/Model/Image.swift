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
        public let tags: [String]

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
    }
}

extension Docker.Image: CustomStringConvertible {
    public var description: String {
        "[\(id)] \(tags.joined(separator: ", "))"
    }
}

extension Docker.Image {
    internal var namesAndTags: [(name: String, tag: String)] {
        tags.reduce(into: []) { tags, tag in
            let components = tag.split(separator: ":", maxSplits: 1).map(String.init)
            guard components.count == 2 else { return }
            tags.append((components[0], components[1]))
        }
    }
}
