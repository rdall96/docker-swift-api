//
//  DockerClient.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/22/25.
//

import Foundation
import Logging

public final class DockerClient {
    public typealias RequestTimeout = Int64

    /// The connection used for communicating with Docker.
    public let connection: DockerConnection

    /// Authentication information for communicating with remote registries.
    public var authentication: DockerAuthenticationContext?

    /// Request timeout in seconds.
    public var timeout: RequestTimeout? = nil

    public var logger: Logger

    /// Create a new Docker client to send requests to.
    /// By default it uses the local socket connection (see: `DockerConnection.defaultSocket`).
    public init(
        connection: DockerConnection = .defaultSocket,
        timeout: RequestTimeout? = nil,
        logger: Logger? = nil
    ) {
        self.connection = connection
        self.timeout = timeout
        self.logger = logger ?? Logger(label: "docker-\(connection.description)")
    }

    // MARK: - Run methods

    private var runner: DockerRunner {
        connection.runner(logger: logger)
    }

    @discardableResult
    internal func run<T: DockerRequest>(_ request: T) async throws -> T.Response where T.Response == Void {
        try await runner.run(request, timeout: timeout)
        return
    }

    @discardableResult
    internal func run<T: DockerRequest>(_ request: T) async throws -> T.Response where T.Response : Decodable {
        let response = try await runner.run(request, timeout: timeout)
        guard let data = response.body else {
            throw DockerError.missingResponseBody
        }

        // Decode the response body
        do {
            return try JSONDecoder().decode(T.Response.self, from: data)
        }
        catch {
            throw DockerError.failedToDecodeResponse(error)
        }
    }
}

extension DockerClient: CustomStringConvertible {
    public var description: String {
        "Docker \(connection.description)"
    }
}
