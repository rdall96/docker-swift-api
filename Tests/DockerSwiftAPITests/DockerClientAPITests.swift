//
//  DockerClientAPITests.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Testing
import Foundation

// Not a testable import so we can test this as a public API
import DockerSwiftAPI

struct DockerClientAPITests {

    // Fix the tests to the specific API version
    let client = DockerClient(api: .v1_51)

    @Test
    func ping() async throws {
        #expect(await client.isAvailable)
    }

    @Test
    func systemVersion() async throws {
        let version = try await client.version
        #expect(version.platform.name.isEmpty == false)
        #expect(version.components.isEmpty == false)
        #expect(version.version.major >= 27)
        #expect(version.apiVersion.major == 1)
        #expect(version.apiVersion.minor == 51)
    }

    @Test
    func fetchImages() async throws {
        _ = try await client.images
        // there's no point in checking anything here
        // since we don't know what images might be on the host that runs the tests
    }

    @Test
    func pullImage() async throws {
        try await client.pull("hello-world", tag: "nanoserver")
        try await client.pull("hello-world", digest: "4420cea78cd60f211265c0bb555b3318808beed7b20212fda0eb45cdb7141027")

        let images = try await client.images(withName: "hello-world")
        #expect(images.isEmpty == false)

        let image = try await client.image(withName: "hello-world", tag: "nanoserver")
        #expect(images.contains(image))
    }

    @Test
    func tagImage() async throws {
        try await client.pull("hello-world")
        let image = try await client.image(withName: "hello-world")

        try await client.tagImage(with: image.id, as: "hello-world", tag: "test")
        let newImage = try await client.image(withName: "hello-world", tag: "test")

        #expect(newImage.id == image.id)
    }

    @Test
    func deleteImages() async throws {
        try await client.pull("hello-world")
        for image in try await client.images(withName: "hello-world") {
            try await client.deleteImage(with: image.id, force: true)
        }
        #expect(try await client.images(withName: "hello-world").isEmpty)
    }

    @Test
    func pruneImages() async throws {
        try await client.pull("hello-world")
        let result = try await client.pruneImages()
        // Nothing to delete
        #expect(result.reclaimedSpaceBytes == 0)
    }

    @Test
    func buildImage() async throws {
        let buildDir = try #require(Bundle.module.url(forResource: "TestBuild", withExtension: nil))
        try await client.buildImage(
            at: buildDir,
            ignoreFiles: [
                "ignore_this_file.txt",
            ],
            name: "test",
            tag: "buildImage",
            useCache: false
        )
    }
}
