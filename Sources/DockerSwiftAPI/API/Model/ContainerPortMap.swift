//
//  ContainerPort.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker.Container {
    /// Port-mappings for the container.
    public struct PortMap: Equatable, Hashable, Decodable, Sendable {

        public enum PortType: String, Decodable, Sendable {
            case tcp
            case udp
            case sctp
        }

        /// Port exposed on the host.
        /// `nil` if no port has been mapped.
        public let hostPort: UInt16?

        /// Port on the container.
        public let containerPort: UInt16

        public let type: PortType

        public init(hostPort: UInt16, containerPort: UInt16, type: PortType) {
            self.hostPort = hostPort
            self.containerPort = containerPort
            self.type = type
        }

        private enum CodingKeys: String, CodingKey {
            case hostPort = "PublicPort"
            case containerPort = "PrivatePort"
            case type = "Type"
        }
    }
}

extension Docker.Container.PortMap: CustomStringConvertible {
    public var description: String {
        "\(hostPort?.formatted() ?? "-"):\(containerPort)/\(type.rawValue)"
    }
}
