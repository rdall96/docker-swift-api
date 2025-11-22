//
//  Info.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker {
    // unused
    /// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/System/operation/SystemInfo
    internal struct Info: Decodable, Sendable {
        let id: UUID
        let containers: UInt
        let runningContainers: UInt
        let pausedContainers: UInt
        let stoppedContainers: UInt
        let images: UInt
        let driver: String
        let memoryLimit: Bool
        let swapLimit: Bool
        let cpuCfsPeriod: Bool
        let cpuCfsQuota: Bool
        let cpuShares: Bool
        let cpuSet: Bool
        let pidsLimit: Bool
        let ipv4Forwarding: Bool
        let kernelVersion: String
        let operatingSystem: String
        let osVersion: String
        let osType: String
        let architecture: String
        let indexServerAddress: String
        let nCpu: UInt
        let memoryTotalBytes: UInt
        let dockerRootDir: String
        let name: String
        let serverVersion: Docker.Version

        private enum CodingKeys: String, CodingKey {
            case id = "ID"
            case containers = "Containers"
            case runningContainers = "ContainersRunning"
            case pausedContainers = "ContainersPaused"
            case stoppedContainers = "ContainersStopped"
            case images = "Images"
            case driver = "Driver"
            case memoryLimit = "MemoryLimit"
            case swapLimit = "SwapLimit"
            case cpuCfsPeriod = "CpuCfsPeriod"
            case cpuCfsQuota = "CpuCfsQuota"
            case cpuShares = "CPUShares"
            case cpuSet = "CPUSet"
            case pidsLimit = "PidsLimit"
            case ipv4Forwarding = "IPv4Forwarding"
            case kernelVersion = "KernelVersion"
            case operatingSystem = "OperatingSystem"
            case osVersion = "OSVersion"
            case osType = "OSType"
            case architecture = "Architecture"
            case indexServerAddress = "IndexServerAddress"
            case nCpu = "NCPU"
            case memoryTotalBytes = "MemTotal"
            case dockerRootDir = "DockerRootDir"
            case name = "Name"
            case serverVersion = "ServerVersion"
        }
    }
}
