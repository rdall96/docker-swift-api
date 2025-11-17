//
//  PingRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/System/operation/SystemPing
fileprivate struct DockerPingRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = Void

    let endpoint: String = "/_ping"
}

extension Docker {
    /// Check if the client is reachable.
    public static var isAvailable: Bool {
        get async {
            do {
                try await DockerPingRequest().start()
                return true
            }
            catch {
                return false
            }
        }
    }
}
