//
//  Docker+BuildImage.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

/// Build an image.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageBuild
public struct DockerBuildImageRequest: DockerRequest {
    public typealias Response = Void

    public struct Query: Encodable {
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

    public let method: DockerRequest.Method = .POST
    public let endpoint: String = "/build"
    public let query: Query?
    public let body: Data?
    public let contentType: ContentType = .tar

    public init(
        at url: URL,
        ignoreFiles: [String] = [],
        name: String,
        tag: String = "latest",
        dockerFilePath: String = "Dockerfile",
        buildArgs: Docker.BuildArgs? = nil,
        labels: Docker.Labels? = nil,
        useCache: Bool = true
    ) throws {
        let imageName = Self.sanitizeImageName(name)
        let taggedImage = "\(imageName):\(tag)"

        // Create the build query
        query = .init(
            dockerFile: dockerFilePath,
            tag: taggedImage,
            noCache: !useCache,
            buildArgs: buildArgs?.args,
            labels: labels?.labels
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
    public func start() async throws -> Docker.Image {
        try await run()

        // Find the newly built image and return it
        let images = try await DockerImagesRequest().start()
        guard let imageTag = query?.tag,
              let image = images.first(where: { $0.tags.contains(imageTag) })
        else {
            logger.critical("No image found after completing build")
            throw DockerError.imageNotFound
        }
        return image
    }
}
