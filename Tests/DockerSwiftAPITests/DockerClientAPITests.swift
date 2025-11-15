//
//  DockerClientAPITests.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Testing

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
    func version() async throws {
        let version = try await client.version
        #expect(version.platform.name.isEmpty == false)
        #expect(version.components.isEmpty == false)
        #expect(version.version.major >= 27)
        #expect(version.apiVersion.major == 1)
        #expect(version.apiVersion.minor == 51)
    }
}
