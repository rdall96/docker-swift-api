//
//  ContainerHostConfig.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker.Container {
    /// Container configuration that depends on the host we are running on.
    public struct HostConfig: Encodable, Sendable {

        /// Mapping a local directory or Docker volume to a path inside the container.
        public struct VolumeMapping: RawRepresentable, Codable, Sendable {
            public let rawValue: String

            public init(rawValue: String) {
                self.rawValue = rawValue
            }

            private init(source: String, destination: String, isReadOnly: Bool) {
                self.init(rawValue: "\(source):\(destination)\(isReadOnly ? ":ro" : "")")
            }

            public static func bind(hostPath: String, containerPath: String, readOnly: Bool = false) -> Self {
                self.init(source: hostPath, destination: containerPath, isReadOnly: readOnly)
            }

            public static func volume(id: Docker.Volume.ID, containerPath: String, readOnly: Bool = false) -> Self {
                self.init(source: id, destination: containerPath, isReadOnly: readOnly)
            }
        }

        /// Host port that is mapped to a container.
        public struct HostPortInfo: Codable, Sendable {
            let hostPort: String

            internal init(with map: Docker.Container.PortMap) {
                self.hostPort = String(map.hostPort)
            }

            private enum CodingKeys: String, CodingKey {
                case hostPort = "HostPort"
            }
        }

        /// Mapping of ports between the host and the container.
        public typealias PortMappings = [String : [HostPortInfo]]

        private struct RestartPolicyConfig: RawRepresentable, Codable, Sendable {
            let rawValue: Docker.Container.RestartPolicy

            init(rawValue: Docker.Container.RestartPolicy) {
                self.rawValue = rawValue
            }

            private enum CodingKeys: String, CodingKey {
                case name = "Name"
                case maxRetryCount = "MaximumRetryCount"
            }

            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let name = try container.decode(String.self, forKey: .name)
                let retryCount = try container.decodeIfPresent(Int.self, forKey: .maxRetryCount)
                rawValue = .init(name: name, retryCount: retryCount)
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(rawValue.name, forKey: .name)
                try container.encodeIfPresent(rawValue.retryCount, forKey: .maxRetryCount)
            }
        }

        /// An integer value representing this container's relative CPU weight versus other containers.
        public let cpuShares: Int?

        /// Memory limit in bytes.
        /// Default: 0
        public let memoryLimitBytes: Int64

        /// Memory soft limit in bytes.
        public let reservedMemoryBytes: Int64?

        /// A list of volume bindings for this container.
        public let volumeMappings: [VolumeMapping]

        /// Mapping of container ports to host ports.
        public let portMappings: PortMappings

        private let restartPolicyConfig: RestartPolicyConfig?
        /// The behavior to apply when the container exits. The default is not to restart.
        public var restartPolicy: Docker.Container.RestartPolicy {
            restartPolicyConfig?.rawValue ?? .default
        }

        /// Automatically remove the container when the container's process exits.
        /// This has no effect if `restartPolicy` is set.
        public let autoRemove: Bool

        /// A list of DNS servers for the container to use.
        public let dnsServers: [String]?

        /// Gives the container full access to the host.
        public let privileged: Bool

        public init(
            cpuShares: Int? = nil,
            memoryLimitBytes: Int64 = 0,
            reservedMemoryBytes: Int64? = nil,
            volumeMappings: [VolumeMapping] = [],
            portMappings: [Docker.Container.PortMap] = [],
            restartPolicy: Docker.Container.RestartPolicy? = nil,
            autoRemove: Bool = false,
            dnsServers: [String]? = nil,
            privileged: Bool = false
        ) {
            self.cpuShares = cpuShares
            self.memoryLimitBytes = memoryLimitBytes
            self.reservedMemoryBytes = reservedMemoryBytes
            self.volumeMappings = volumeMappings
            self.portMappings = portMappings.reduce(into: PortMappings()) { result, portMap in
                result[portMap.containerPortDescription] = [
                    HostPortInfo(with: portMap)
                ]
            }
            if let restartPolicy {
                restartPolicyConfig = .init(rawValue: restartPolicy)
            }
            else {
                restartPolicyConfig = nil
            }
            self.autoRemove = autoRemove
            self.dnsServers = dnsServers
            self.privileged = privileged
        }


        private enum CodingKeys: String, CodingKey {
            case cpuShares = "CpuShares"
            case memoryLimitBytes = "Memory"
            case reservedMemoryBytes = "MemoryReservation"
            case volumeMappings = "Binds"
            case portMappings = "PortBindings"
            case restartPolicyConfig = "RestartPolicy"
            case autoRemove = "AutoRemove"
            case dnsServers = "Dns"
            case privileged = "Privileged"
        }
    }
}

fileprivate extension Docker.Container.PortMap {
    var containerPortDescription: String { "\(containerPort)/\(type.rawValue)" }
}

fileprivate extension Docker.Container.RestartPolicy {

    init(name: String, retryCount: Int?) {
        switch name.lowercased() {
        case "always":
            self = .always
        case "unless-stopped":
            self = .unlessStopped
        case "on-failure":
            self = .onFailure(retryCount: retryCount)
        default:
            self = .never
        }
    }

    var name: String {
        switch self {
        case .never: "no"
        case .always: "always"
        case .unlessStopped: "unless-stopped"
        case .onFailure: "on-failure"
        }
    }

    var retryCount: Int? {
        switch self {
        case .onFailure(let retryCount): retryCount
        default: nil
        }
    }
}
