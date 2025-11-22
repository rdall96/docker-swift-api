//
//  DockerConnection+Runner.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/22/25.
//

import Foundation
import Logging

extension DockerConnection {
    func runner(logger: Logger) -> DockerRunner {
        switch self {
        case .socket(let path): DockerSocketRunner(path, logger: logger)
        case .server(let host): DockerServerRunner(host: host, logger: logger)
        }
    }
}
