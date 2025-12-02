//
//  Docker.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation
import Logging

/// An instance of a Docker client, which provides methods to communicate with the Docker Engine and perform actions on images, containers, volumes, etc...
public final class Docker {
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

        #if DEBUG
        self.logger.logLevel = .debug
        #else
        self.logger.logLevel = .notice
        #endif
    }
}

extension Docker: CustomStringConvertible {
    public var description: String {
        "Docker \(connection.description)"
    }
}
