//
//  BuildRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

/// Build an image.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageBuild
public struct DockerBuildRequest: DockerRequest {
    public typealias Response = Void

    public struct Query: Encodable {
        let dockerFile: String
        let tag: String
        let noCache: Bool
        let buildArgs: [String : String]?
        let labels: [String : String]?
        let version: String

        private enum CodingKeys: String, CodingKey {
            case dockerFile = "DockerFile"
            case tag = "t"
            case noCache = "nocache"
            case buildArgs = "buildargs"
            case labels
            case version
        }
    }

    public let method: DockerRequest.Method = .POST
    public let endpoint: String = "/build"
    public let query: Query?
    public let body: Data?
    public let contentType: ContentType = .tar

    private let tag: Docker.Image.Tag

    public init(
        at url: URL,
        ignoreFiles: [String] = [],
        tag: Docker.Image.Tag,
        dockerFilePath: String = "Dockerfile",
        buildArgs: Docker.BuildArgs? = nil,
        labels: Docker.Labels? = nil,
        useCache: Bool = true,
        useBuildKit: Bool = false
    ) throws {
        self.tag = tag

        // Create the build query
        query = .init(
            dockerFile: dockerFilePath,
            tag: tag.description,
            noCache: !useCache,
            buildArgs: buildArgs?.args,
            labels: labels?.labels,
            version: useBuildKit ? "2" : "1"
        )

        // Pack up the build context directory, load the data and remove any tempoary files
        let buildContextURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).tar.gz")
        defer { try? FileManager.default.removeItem(at: buildContextURL) }

        do {
            try FileManager.default.createTarGz(of: url, at: buildContextURL, excluding: ignoreFiles)
            body = try Data(contentsOf: buildContextURL)
        }
        catch {
            throw DockerError.systemError(error)
        }
    }

    /// Run the request and return the newly built image object.
    public func start(timeout: Int64? = nil) async throws -> Docker.Image {
        try await run(timeout: timeout)

        // Find the newly built image and return it
        guard let image = try await DockerImagesRequest.image(tag: tag) else {
            logger.critical("No image found after completing build")
            throw DockerError.imageNotFound
        }
        return image
    }
}
