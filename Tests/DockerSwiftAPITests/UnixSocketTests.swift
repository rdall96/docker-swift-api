//
//  UnixSocketTests.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/14/25.
//

import Testing
import Foundation
import NIOHTTP1
import AsyncHTTPClient

@testable import DockerSwiftAPI

final class UnixSocketTests {

    private let socket: UnixSocket

    init() {
        socket = UnixSocket("/var/run/docker.sock", hostname: "v1.51")
        print(socket.description)
    }

    deinit {
        try? socket.shutdown()
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

    private struct CreateDockerContainerRequest: UnixSocketRequest {
        typealias Query = Never

        struct Context: Encodable {
            let Image: String
        }

        let method: HTTPMethod = .POST
        let path: String = "containers/create"
        let body: Context?

        init(image: String) {
            body = .init(Image: image)
        }

        struct Response: Decodable {
            let Id: String
        }
    }

    @Test
    func startContainer() async throws {
        let pullResponse = try await socket.run("images/create?fromImage=hello-world", method: .POST)
        #expect(pullResponse.status == .ok)

        let createResponse = try await socket.run(CreateDockerContainerRequest(image: "hello-world"))
        #expect(createResponse.Id.isEmpty == false)
    }
}
