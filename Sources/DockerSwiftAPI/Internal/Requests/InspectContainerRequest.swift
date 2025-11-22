//
//  InspectContainerRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/22/25.
//

import Foundation

/// Return low-level information about a container.
/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/Container/operation/ContainerInspect
//internal struct InspectContainerRequest: DockerRequest {
//    typealias Query = Never
//    typealias Body = Never
//    typealias Response = Docker.Container
//
//    let endpoint: String
//
//    init(containerID: Docker.Container.ID) {
//        endpoint = "/containers/\(containerID)/json"
//    }
//}
