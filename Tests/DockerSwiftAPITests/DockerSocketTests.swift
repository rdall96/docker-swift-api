//
//  DockerSocketTests.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/14/25.
//

import Testing
import Foundation
import NIOHTTP1
import AsyncHTTPClient

@testable import DockerSwiftAPI

final class DockerSocketTests {

    private let socket: DockerSocket

    init() {
        socket = DockerSocket("/var/run/docker.sock", hostname: "v1.51")
    }

    deinit {
        socket.shutdown()
    }

    private func encode<T: Encodable>(_ value: T) throws -> HTTPClient.Body {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        return .data(data)
    }

    @Test
    func version() async throws {
        let response = try await socket.run("version")
        #expect(response.status == .ok)
        let result = String(buffer: try #require(response.body))
        #expect(result.isEmpty == false)
    }

    @Test
    func startContainer() async throws {
        let pullResponse = try await socket.run("images/create?fromImage=hello-world", method: .POST)
        #expect(pullResponse.status == .ok)
    }
}
