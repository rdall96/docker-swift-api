//
//  DockerClient+BuildImage.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation
import NIOHTTP1

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageBuild
fileprivate struct BuildRequest: DockerRequest {
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
    let path: String = "/build"
    let query: Query?
    let body: Body?
    let contentType: ContentType = .tar
}

extension DockerClient {
    /// Build an image at the given directory using the provided configuration.
    public func buildImage(
        at url: URL,
        ignoreFiles: [String] = [],
        name: String,
        tag: String = "latest",
        dockerFilePath: String = "Dockerfile",
        buildArgs: Docker.BuildArgs? = nil,
        labels: Docker.Labels? = nil,
        useCache: Bool = true,
    ) async throws(DockerError) -> Docker.Image {
        let compressedFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).tar.gz")
        defer { try? FileManager.default.removeItem(at: compressedFileURL) }

        let buildData: Data
        do {
            try FileManager.default.createTarGz(of: url, at: compressedFileURL, excluding: ignoreFiles)
            buildData = try Data(contentsOf: compressedFileURL)
        }
        catch {
            logger.error("Failed to pack build files at \(url): \(error)")
            throw .systemError(error)
        }

        let imageName = BuildRequest.imageName(from: name)
        let fullImageName = "\(imageName):\(tag)"

        // Build the request
        let request = BuildRequest(
            query: .init(
                dockerFile: dockerFilePath,
                tag: fullImageName,
                noCache: !useCache,
                buildArgs: buildArgs?.args,
                labels: labels?.labels
            ),
            body: buildData
        )

        // Run the build
        try await run(request)

        // Find the newly built image and return it
        guard let image = try await image(withName: imageName, tag: tag) else {
            logger.critical("Image \(fullImageName) built with no errors, but no image found!")
            throw .imageNotFound
        }
        return image
    }
}
