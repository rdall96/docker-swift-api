//
//  PingRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/System/operation/SystemPing
internal struct PingRequest: DockerRequest {
    typealias Query = Never
    typealias Body = Never
    typealias Response = Void

    let endpoint: String = "_ping"
}
