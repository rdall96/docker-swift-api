//
//  Container.swift
//  
//
//  Created by Ricky Dall'Armellina on 7/19/23.
//

import Foundation

// MARK: - Container
extension Docker {
    public struct Container: Equatable, Hashable {
        public let id: String
        public let name: String?
        public let image: Image
        
        /// Create a container object from the docker command output and the given container specifications
        init(_ id: String, name: String? = nil, image: Image) throws {
            let id = id.replacingOccurrences(of: "\n", with: "")
            // FIXME: (2025/11/16) This will get restored at a later date
//            guard !id.isEmpty else {
//                throw DockerError.missingContainerId
//            }
            self.id = id
            self.name = name
            self.image = image
        }
    }
}

// MARK: - Container Status
extension Docker.Container {
    public enum Status {
        case created
        case running
        case restarting
        case exited
        case paused
        case unknown
        
        init(from description: String) {
            switch description.lowercased() {
            case "created":
                self = .created
            case "running":
                self = .running
            case "restarting":
                self = .restarting
            case "exited":
                self = .exited
            default:
                self = .unknown
            }
        }
    }
}

// MARK: - Container Stats
extension Docker.Container {
    public struct Stats {
        public let cpuPercent: Double
        public let memoryPercent: Double
        public let memoryUsageBytes: UInt
        public let memoryLimitBytes: UInt
        public let networkDownloadBytes: UInt
        public let networkUploadBytes: UInt
        
        init(
            cpuPercent: Double,
            memoryPercent: Double,
            memoryUsageBytes: UInt,
            memoryLimitBytes: UInt,
            networkDownloadBytes: UInt,
            networkUploadBytes: UInt
        ) {
            self.cpuPercent = cpuPercent
            self.memoryPercent = memoryPercent
            self.memoryUsageBytes = memoryUsageBytes
            self.memoryLimitBytes = memoryLimitBytes
            self.networkDownloadBytes = networkDownloadBytes
            self.networkUploadBytes = networkUploadBytes
        }
    }
}

extension Docker.Container.Stats: Decodable {
    /*
     {
         "BlockIO": "0B / 0B",
         "CPUPerc": "0.00%",
         "Container": "626c0c043861",
         "ID": "626c0c043861",
         "MemPerc": "0.00%",
         "MemUsage": "0B / 0B",
         "Name": "quizzical_hellman",
         "NetIO": "0B / 0B",
         "PIDs": "0"
     }
     */
    
    private enum CodingKeys: String, CodingKey {
        case cpuPercent = "CPUPerc"
        case memoryPercent = "MemPerc"
        case memoryBytes = "MemUsage"
        case networkBytes = "NetIO"
    }
    
    private init(
        cpuPercent: String,
        memoryPercent: String,
        memoryBytes: String,
        networkBytes: String
    ) {
        self.cpuPercent = Double(cpuPercent.replacingOccurrences(of: "%", with: "")) ?? 0
        self.memoryPercent = Double(memoryPercent.replacingOccurrences(of: "%", with: "")) ?? 0
        
        let memory = memoryBytes.split(separator: "/")
            .compactMap {
                String($0)
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "B", with: "")
            }
        self.memoryUsageBytes = (memory.count == 2) ? (UInt(memory[0]) ?? 0) : 0
        self.memoryLimitBytes = (memory.count == 2) ? (UInt(memory[1]) ?? 0) : 0
        
        let network = networkBytes.split(separator: "/")
            .compactMap {
                String($0)
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "B", with: "")
            }
        self.networkDownloadBytes = (network.count == 2) ? (UInt(network[0]) ?? 0) : 0
        self.networkUploadBytes = (network.count == 2) ? (UInt(network[1]) ?? 0) : 0
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            cpuPercent: try container.decode(String.self, forKey: .cpuPercent),
            memoryPercent: try container.decode(String.self, forKey: .memoryPercent),
            memoryBytes: try container.decode(String.self, forKey: .memoryBytes),
            networkBytes: try container.decode(String.self, forKey: .networkBytes)
        )
    }
}

extension Docker.Container.Stats {
    static var empty: Docker.Container.Stats {
        .init(
            cpuPercent: 0,
            memoryPercent: 0,
            memoryUsageBytes: 0,
            memoryLimitBytes: 0,
            networkDownloadBytes: 0,
            networkUploadBytes: 0
        )
    }
}
