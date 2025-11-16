//
//  DockerClient+Images.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation
import NIOHTTP1

// MARK: - List images

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageList
fileprivate struct FetchImagesRequest: UnixSocketRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = [Docker.Image]

    let method: HTTPMethod = .GET
    let path: String = "images/json"
}

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageInspect
fileprivate struct InspectImageRequest: UnixSocketRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = Docker.Image
    
    let method: HTTPMethod = .GET
    let path: String

    init(image: String) {
        path = "images/\(image)/json"
    }
}

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageCreate
fileprivate struct PullImageRequest: UnixSocketRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let image: String
        let tag: String?

        private enum CodingKeys: String, CodingKey {
            case image = "fromImage"
            case tag
        }
    }

    let method: HTTPMethod = .POST
    let path: String = "images/create"
    let query: Query?

    init(image: String, tag: String? = nil) {
        query = .init(
            image: image.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true).map(String.init).first ?? image,
            tag: tag
        )
    }

    init(image: String, digest: String) {
        var digest = digest
        if !digest.hasPrefix("sha256:") {
            digest = "sha256:\(digest)"
        }
        let image = image.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true).map(String.init).first ?? image
        query = .init(image: image + "@" + digest, tag: nil)
    }
}

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageTag
fileprivate struct TagImageRequest: UnixSocketRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let repo: String
        let tag: String
    }

    let method: HTTPMethod = .POST
    let path: String
    let query: Query?

    init(imageID: String, newName: String, newTag: String) {
        self.path = "images/\(imageID)/tag"
        query = .init(repo: newName, tag: newTag)
    }
}

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageDelete
fileprivate struct RemoveImageRequest: UnixSocketRequest {
    typealias Body = Never
    typealias Response = Void

    struct Query: Encodable {
        let force: Bool
        let noPrune: Bool

        private enum CodingKeys: String, CodingKey {
            case force
            case noPrune = "noprune"
        }
    }

    let method: HTTPMethod = .DELETE
    let path: String
    let query: Query?

    init(imageID: String, force: Bool, noPrune: Bool) {
        path = "images/\(imageID)"
        query = .init(force: force, noPrune: noPrune)
    }
}

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImagePrune
fileprivate struct PruneImagesRequest: UnixSocketRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = DockerClient.PruneImagesResult

    let method: HTTPMethod = .POST
    let path: String = "images/prune"
}

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageBuild
fileprivate struct BuildRequest: UnixSocketRequest {
    typealias Body = Data
    typealias Response = Void

    struct Query: Encodable {
        let dockerFile: String
        let tag: String
        let noCache: Bool
        let buildArgs: [String : String]?
        let labels: [String : String]?
        // FIXME: Figure out how to use version 2: [BuildKit](https://github.com/moby/buildkit)
        let version: String = "1"

        private enum CodingKeys: String, CodingKey {
            case dockerFile = "DockerFile"
            case tag = "t"
            case noCache = "nocache"
            case buildArgs = "buildargs"
            case labels
            case version
        }
    }

    let method: HTTPMethod = .POST
    let path: String = "build"
    let query: Query?
    let body: Body?
    let contentType: ContentType = .tar
}

extension DockerClient {

    /// List all images on the system.
    public var images: [Docker.Image] {
        get async throws {
            try await socket.run(FetchImagesRequest())
        }
    }

    /// List all images with the given name.
    public func images(withName name: String) async throws -> [Docker.Image] {
        try await images.filter { $0.tags.joined().contains(name) }
    }

    /// Returns details about an image with the given ID, if it exists.
    public func image(with id: Docker.Image.ID) async throws -> Docker.Image {
        let request = InspectImageRequest(image: id)
        return try await socket.run(request)
    }

    /// Returns details an image with the given name and tag, if it exists.
    public func image(withName name: String, tag: String = "latest") async throws -> Docker.Image {
        let request = InspectImageRequest(image: "\(name):\(tag)")
        return try await socket.run(request)
    }

    /// Pull an image by name.
    public func pull(_ image: String, tag: String = "latest") async throws {
        let request = PullImageRequest(image: image, tag: tag)
        try await socket.run(request)
    }

    /// Pull an image by digest.
    public func pull(_ image: String, digest: String) async throws {
        let request = PullImageRequest(image: image, digest: digest)
        try await socket.run(request)
    }

    /// Tag an image.
    public func tagImage(with id: Docker.Image.ID, as name: String, tag: String = "latest") async throws {
        let request = TagImageRequest(imageID: id, newName: name, newTag: tag)
        try await socket.run(request)
    }

    /// Delete an image.
    public func deleteImage(with id: Docker.Image.ID, force: Bool = false, prune: Bool = true) async throws {
        let request = RemoveImageRequest(imageID: id, force: force, noPrune: !prune)
        try await socket.run(request)
    }

    /// Result object for an image prune action.
    public struct PruneImagesResult: Decodable {

        public struct Record: Decodable {
            public let untagged: String
            public let deleted: String

            private enum CodingKeys: String, CodingKey {
                case untagged = "Untagged"
                case deleted = "Deleted"
            }
        }

        public let reclaimedSpaceBytes: Int64
        public let records: [Record]?

        private enum CodingKeys: String, CodingKey {
            case reclaimedSpaceBytes = "SpaceReclaimed"
            case records = "ImagesDeleted"
        }
    }

    /// Remove unused images.
    public func pruneImages() async throws -> PruneImagesResult {
        try await socket.run(PruneImagesRequest())
    }

    /// Build an image at the given directory using the provided configuration.
    public func buildImage(
        at url: URL,
        ignoreFiles: [String] = [],
        name: String,
        tag: String = "latest",
        dockerFilePath: String = "Dockerfile",
        buildArgs: [String : String]? = nil,
        labels: Docker.Labels? = nil,
        useCache: Bool = true,
    ) async throws {
        let compressedFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).tar.gz")
        defer { try? FileManager.default.removeItem(at: compressedFileURL) }
        try FileManager.default.createTarGz(of: url, at: compressedFileURL, excluding: ignoreFiles)

        // Build the request
        let request = BuildRequest(
            query: .init(
                dockerFile: dockerFilePath,
                tag: "\(name):\(tag)",
                noCache: !useCache,
                buildArgs: buildArgs,
                labels: labels
            ),
            body: try Data(contentsOf: compressedFileURL)
        )

        // Run the build
        try await socket.run(request)
    }
}
