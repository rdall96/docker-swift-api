//
//  DockerClient+Ping.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation
import NIOHTTP1

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/System/operation/SystemPing
fileprivate struct PingRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = Void

    let method: HTTPMethod = .GET
    let path: String = "/_ping"
}

extension DockerClient {
    /// Check if the client is reachable.
    public var isAvailable: Bool {
        get async {
            do {
                try await run(PingRequest())
                return true
            }
            catch {
                return false
            }
        }
    }
}
