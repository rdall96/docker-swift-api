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
import Logging

@testable import DockerSwiftAPI

struct DockerSocketTests {

    private let socket: DockerSocketRunner

    init() {
        socket = DockerSocketRunner("/var/run/docker.sock", logger: Logger(label: "DockerSocketTests"))
    }

    private func encode<T: Encodable>(_ value: T) throws -> HTTPClient.Body {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        return .data(data)
    }

    @Test
    func version() async throws {
        let response = try await socket.response(
            for: "version",
            method: .GET,
            body: nil,
            headers: [:],
            timeout: nil
        )
        #expect(response.status == .ok)
        let result = String(buffer: try #require(response.body))
        #expect(result.isEmpty == false)
    }

    @Test
    func startContainer() async throws {
        let response = try await socket.response(
            for: "images/create?fromImage=hello-world",
            method: .POST,
            body: nil,
            headers: [:],
            timeout: nil
        )
        #expect(response.status == .ok)
    }
}
