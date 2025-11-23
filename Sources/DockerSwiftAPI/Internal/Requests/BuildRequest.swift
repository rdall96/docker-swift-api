//
//  BuildRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

/// Build an image.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Image/operation/ImageBuild
internal struct BuildImageRequest: DockerRequest {
    typealias Response = Void

    struct Query: Encodable {
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

    let method: DockerRequest.Method = .POST
    let endpoint: String = "/build"
    let query: Query?
    let body: Data?
    let contentType: ContentType = .tar

    init(
        buildDirectoryURL: URL,
        ignoreFiles: [String],
        tag: Docker.Image.Tag,
        dockerFilePath: String,
        buildArgs: Docker.BuildArgs?,
        labels: Docker.Labels?,
        useCache: Bool,
        useBuildKit: Bool
    ) throws {
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
            try FileManager.default.createTarGz(of: buildDirectoryURL, at: buildContextURL, excluding: ignoreFiles)
            body = try Data(contentsOf: buildContextURL)
        }
        catch {
            throw DockerError.buildFailed(error)
        }
    }
}
