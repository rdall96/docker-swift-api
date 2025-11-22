//
//  DockerSocketRunner.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/14/25.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient
import Logging

internal final class DockerSocketRunner: DockerRunner {
    private static let api: String = "v1.51"

    let socket: String
    let client: HTTPClient

    let logger: Logging.Logger

    init(_ socket: String, logger: Logging.Logger) {
        self.socket = socket
        self.client = HTTPClient(eventLoopGroupProvider: .singleton)
        self.logger = logger

//        client.configuration.tlsConfiguration = .makeServerConfigurationWithMTLS(certificateChain: <#T##[NIOSSLCertificateSource]#>, privateKey: .privateKey(.), trustRoots: .)
    }

    /// The HTTPClient must be shutdown properly to avoid crashes.
    deinit {
        do {
            try client.syncShutdown()
        }
        catch {
            logger.critical("Failed to close socket: \(error)")
        }
    }

    /// Send a request to the socket.
    func response(
        for path: String,
        method: HTTPMethod,
        body: HTTPClient.Body?,
        headers: HTTPHeaders,
        timeout: Int64?
    ) async throws -> HTTPClient.Response {
        // add Host header which is required on the socket
        var headers = headers
        headers.add(name: "Host", value: Self.api)

        var deadline: NIODeadline?
        if let timeout {
            deadline = .now() + .seconds(timeout)
        }

        return try await client.execute(
            on: socket,
            method,
            path: "/\(Self.api)/\(path)",
            body: body,
            headers: headers,
            deadline: deadline
        )
    }
}

fileprivate extension HTTPClient {
    /// Run requests on a unix socket.
    func execute(
        on socket: String,
        _ method: HTTPMethod,
        path: String,
        body: Body?,
        headers: HTTPHeaders,
        deadline: NIODeadline? = nil
    ) async throws -> Response {
        guard let url = URL(httpURLWithSocketPath: socket, uri: path) else {
            throw HTTPClientError.invalidURL
        }
        let request = try Request(url: url, method: method, headers: headers, body: body)
        return try await execute(request: request, deadline: deadline, logger: Logger(label: "HTTPClient (socket)")).get()
    }
}
