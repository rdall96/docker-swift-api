//
//  ContainerRestartPolicy.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker.Container {

    /// The behavior to apply when the container exits. The default is not to restart.
    /// An ever increasing delay (double the previous delay, starting at 100ms) is added before each restart to prevent flooding the server.
    public enum RestartPolicy {
        case never
        case always
        case unlessStopped
        case onFailure(retryCount: Int? = nil)

        static let `default`: Self = .never
    }
}
