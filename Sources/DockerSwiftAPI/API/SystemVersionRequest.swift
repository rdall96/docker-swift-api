//
//  SystemVersionRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

/// Fetch the version information from this client.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/System/operation/SystemVersion
fileprivate struct DockerSystemVersionRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = Docker.SystemVersion

    let endpoint: String = "/version"

    internal init() {}
}

extension Docker {
    public static var systemVersion: Docker.SystemVersion {
        get async throws {
            try await DockerSystemVersionRequest().start()
        }
    }
}
