//
//  ContainerSpec.swift
//  
//
//  Created by Ricky Dall'Armellina on 7/19/23.
//

import Foundation

extension Docker {
    public struct ContainerSpec {
        public let attachStdIn: Bool
        public let attachStdOut: Bool
        public let attachStdErr: Bool
        public let cpuCount: UInt?
        public let entrypoint: String?
        public let environment: [String]
        public let hostname: String?
        public let interactive: Bool
        public let labels: [String:String]
        public let memoryLimitBytes: UInt?
        public let reservedMemoryBytes: UInt?
        public let name: String?
        public let ports: [UInt:UInt]
        public let restartPolicy: RestartPolicy
        public let tty: Bool
        public let volumes: [String:String]
        
        public init(
            attachStdIn: Bool = false,
            attachStdOut: Bool = false,
            attachStdErr: Bool = false,
            cpuCount: UInt? = nil,
            entrypoint: String? = nil,
            environment: [String] = [],
            hostname: String? = nil,
            interactive: Bool = false,
            labels: [String:String] = [:],
            memoryLimitBytes: UInt? = nil,
            reservedMemoryBytes: UInt? = nil,
            name: String? = nil,
            ports: [UInt:UInt] = [:],
            restartPolicy: RestartPolicy = .no,
            tty: Bool = false,
            volumes: [String:String] = [:]
        ) {
            self.attachStdIn = attachStdIn
            self.attachStdOut = attachStdOut
            self.attachStdErr = attachStdErr
            self.cpuCount = cpuCount
            self.entrypoint = entrypoint
            self.environment = environment
            self.hostname = hostname
            self.interactive = interactive
            self.labels = labels
            self.memoryLimitBytes = memoryLimitBytes
            self.reservedMemoryBytes = reservedMemoryBytes
            self.name = name
            self.ports = ports
            self.restartPolicy = restartPolicy
            self.tty = tty
            self.volumes = volumes
        }
        
        var options: [String] {
            var args: [String] = [
                "--quiet" // always use this flag to avoid showing image pull output
            ]
            
            if attachStdIn {
                args.append("--attach STDIN")
            }
            if attachStdOut {
                args.append("--attach STDOUT")
            }
            if attachStdErr {
                args.append("--attach STDERR")
            }
            if let cpuCount {
                args.append("--cpus \(cpuCount)")
            }
            if let entrypoint {
                args.append("--entrypoint \(entrypoint)")
            }
            for env in environment {
                args.append("--env \"\(env)\"")
            }
            if let hostname {
                args.append("--hostname \(hostname)")
            }
            if interactive {
                args.append("--interactive")
            }
            for label in labels {
                args.append("--label \(label.key)=\(label.value)")
            }
            if let memoryLimitBytes {
                args.append("--memory \(memoryLimitBytes)")
            }
            if let reservedMemoryBytes {
                args.append("--memory-reservation \(reservedMemoryBytes)")
            }
            if let name {
                args.append("--name \(name)")
            }
            for port in ports {
                args.append("--publish \(port.key):\(port.value)")
            }
            args.append("--restart \(restartPolicy.value)")
            if tty {
                args.append("--tty")
            }
            for volume in volumes {
                args.append("--volume \(volume.key):\(volume.value)")
            }
            
            return args
        }
    }
}

extension Docker.ContainerSpec {
    public enum RestartPolicy {
        case no
        case onFailure(UInt)
        case always
        case unlessStopped
        
        var value: String {
            switch self {
            case .no:
                return "no"
            case .onFailure(let maxRetries):
                return "on-failure:\(maxRetries)"
            case .always:
                return "always"
            case .unlessStopped:
                return "unless-stopped"
            }
        }
    }
}
