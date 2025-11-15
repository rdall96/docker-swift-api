//
//  DockerClient.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation
import NIOHTTP1
import AsyncHTTPClient
import Logging

public final class DockerClient {
    public typealias Socket = String

    internal let socket: UnixSocket
    internal let logger: Logger

    public init(name: String = "docker-local", socket: Socket = "/var/run/docker.sock", api: DockerAPIVersion = .latest) {
        logger = Logger(label: name)
        self.socket = UnixSocket(socket, hostname: api.rawValue, logger: logger)
    }

    deinit {
        try? socket.shutdown()
    }
}
