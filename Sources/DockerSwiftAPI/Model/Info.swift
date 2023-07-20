//
//  Info.swift
//
//
//  Created by Ricky Dall'Armellina on 7/20/23.
//

import Foundation

extension Docker {
    public struct Info {
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
    }
}

extension Docker.Info: Decodable {
    /*
     {
         "ID": "3bde9501-cabd-48dc-952e-71b3751aaff4",
         "Containers": 0,
         "ContainersRunning": 0,
         "ContainersPaused": 0,
         "ContainersStopped": 0,
         "Images": 0,
         "Driver": "overlay2",
         "DriverStatus": [
             [
                 "Backing Filesystem",
                 "extfs"
             ],
             [
                 "Supports d_type",
                 "true"
             ],
             [
                 "Using metacopy",
                 "false"
             ],
             [
                 "Native Overlay Diff",
                 "true"
             ],
             [
                 "userxattr",
                 "false"
             ]
         ],
         "Plugins": {
             "Volume": [
                "local"
             ],
             "Network": [
                 "bridge",
                 "host",
                 "ipvlan",
                 "macvlan",
                 "null",
                 "overlay"
             ],
             "Authorization": null,
             "Log": [
                 "awslogs",
                 "fluentd",
                 "gcplogs",
                 "gelf",
                 "journald",
                 "json-file",
                 "local",
                 "logentries",
                 "splunk",
                 "syslog"
             ]
         },
         "MemoryLimit": true,
         "SwapLimit": true,
         "CpuCfsPeriod": true,
         "CpuCfsQuota": true,
         "CPUShares": true,
         "CPUSet": true,
         "PidsLimit": true,
         "IPv4Forwarding": true,
         "BridgeNfIptables": true,
         "BridgeNfIp6tables": true,
         "Debug": false,
         "NFd": 45,
         "OomKillDisable": false,
         "NGoroutines": 69,
         "SystemTime": "2023-07-20T13:54:26.709388555Z",
         "LoggingDriver": "json-file",
         "CgroupDriver": "cgroupfs",
         "CgroupVersion": "2",
         "NEventsListener": 11,
         "KernelVersion": "5.15.49-linuxkit-pr",
         "OperatingSystem": "Docker Desktop",
         "OSVersion": "",
         "OSType": "linux",
         "Architecture": "aarch64",
         "IndexServerAddress": "https://index.docker.io/v1/",
         "RegistryConfig": {
             "AllowNondistributableArtifactsCIDRs": null,
             "AllowNondistributableArtifactsHostnames": null,
             "InsecureRegistryCIDRs": [
                "127.0.0.0/8"
             ],
             "IndexConfigs": {
                "docker.io": {
                    "Name": "docker.io",
                     "Mirrors": [],
                     "Secure": true,
                     "Official": true
                 },
                 "hubproxy.docker.internal:5555": {
                     "Name": "hubproxy.docker.internal:5555",
                     "Mirrors": [],
                     "Secure": false,
                     "Official": false
                 }
             },
         "Mirrors": null
         },
         "NCPU": 4,
         "MemTotal": 6227877888,
         "GenericResources": null,
         "DockerRootDir": "/var/lib/docker",
         "HttpProxy": "http.docker.internal:3128",
         "HttpsProxy": "http.docker.internal:3128",
         "NoProxy": "hubproxy.docker.internal",
         "Name": "docker-desktop",
         "Labels": [],
         "ExperimentalBuild": false,
         "ServerVersion": "24.0.2",
         "Runtimes": {
             "io.containerd.runc.v2": {
                "path": "runc"
             },
             "runc": {
                "path": "runc"
             }
         },
         "DefaultRuntime": "runc",
         "Swarm": {
             "NodeID": "",
             "NodeAddr": "",
             "LocalNodeState": "inactive",
             "ControlAvailable": false,
             "Error": "",
             "RemoteManagers": null
         },
         "LiveRestoreEnabled": false,
         "Isolation": "",
         "InitBinary": "docker-init",
         "ContainerdCommit": {
             "ID": "3dce8eb055cbb6872793272b4f20ed16117344f8",
             "Expected": "3dce8eb055cbb6872793272b4f20ed16117344f8"
         },
         "RuncCommit": {
             "ID": "v1.1.7-0-g860f061",
             "Expected": "v1.1.7-0-g860f061"
         },
         "InitCommit": {
             "ID": "de40ad0",
             "Expected": "de40ad0"
         },
         "SecurityOptions": [
             "name=seccomp,profile=builtin",
             "name=cgroupns"
         ],
         "Warnings": null,
         "ClientInfo": {
             "Debug": false,
             "Version": "24.0.2",
             "GitCommit": "cb74dfc",
             "GoVersion": "go1.20.4",
             "Os": "darwin",
             "Arch": "arm64",
             "BuildTime": "Thu May 25 21:51:16 2023",
             "Context": "desktop-linux",
             "Plugins": [
                 {
                     "SchemaVersion": "0.1.0",
                     "Vendor": "Docker Inc.",
                     "Version": "v0.10.5",
                     "ShortDescription": "Docker Buildx",
                     "Name": "buildx",
                     "Path": "/Users/ricky/.docker/cli-plugins/docker-buildx",
                     "ShadowedPaths": [
                        "/usr/local/lib/docker/cli-plugins/docker-buildx"
                     ]
                 },
                 {
                     "SchemaVersion": "0.1.0",
                     "Vendor": "Docker Inc.",
                     "Version": "v2.18.1",
                     "ShortDescription": "Docker Compose",
                     "Name": "compose",
                     "Path": "/Users/ricky/.docker/cli-plugins/docker-compose",
                     "ShadowedPaths": [
                        "/usr/local/lib/docker/cli-plugins/docker-compose"
                     ]
                 },
                 {
                     "SchemaVersion": "0.1.0",
                     "Vendor": "Docker Inc.",
                     "Version": "v0.1.0",
                     "ShortDescription": "Docker Dev Environments",
                     "Name": "dev",
                     "Path": "/Users/ricky/.docker/cli-plugins/docker-dev",
                     "ShadowedPaths": [
                        "/usr/local/lib/docker/cli-plugins/docker-dev"
                     ]
                 },
                 {
                     "SchemaVersion": "0.1.0",
                     "Vendor": "Docker Inc.",
                     "Version": "v0.2.19",
                     "ShortDescription": "Manages Docker extensions",
                     "Name": "extension",
                     "Path": "/Users/ricky/.docker/cli-plugins/docker-extension",
                     "ShadowedPaths": [
                        "/usr/local/lib/docker/cli-plugins/docker-extension"
                     ]
                 },
                {
                     "SchemaVersion": "0.1.0",
                     "Vendor": "Docker Inc.",
                     "Version": "v0.1.0-beta.4",
                     "ShortDescription": "Creates Docker-related starter files for your project",
                     "Name": "init",
                     "Path": "/Users/ricky/.docker/cli-plugins/docker-init",
                     "ShadowedPaths": [
                        "/usr/local/lib/docker/cli-plugins/docker-init"
                     ]
                 },
                 {
                     "SchemaVersion": "0.1.0",
                     "Vendor": "Anchore Inc.",
                     "Version": "0.6.0",
                     "ShortDescription": "View the packaged-based Software Bill Of Materials (SBOM) for an image",
                     "URL": "https://github.com/docker/sbom-cli-plugin",
                     "Name": "sbom",
                     "Path": "/Users/ricky/.docker/cli-plugins/docker-sbom",
                     "ShadowedPaths": [
                        "/usr/local/lib/docker/cli-plugins/docker-sbom"
                     ]
                 },
                 {
                     "SchemaVersion": "0.1.0",
                     "Vendor": "Docker Inc.",
                     "Version": "v0.26.0",
                     "ShortDescription": "Docker Scan",
                     "Name": "scan",
                     "Path": "/Users/ricky/.docker/cli-plugins/docker-scan",
                     "ShadowedPaths": [
                        "/usr/local/lib/docker/cli-plugins/docker-scan"
                     ]
                 },
                 {
                     "SchemaVersion": "0.1.0",
                     "Vendor": "Docker Inc.",
                     "Version": "v0.12.0",
                     "ShortDescription": "Command line tool for Docker Scout",
                     "Name": "scout",
                     "Path": "/Users/ricky/.docker/cli-plugins/docker-scout",
                     "ShadowedPaths": [
                        "/usr/local/lib/docker/cli-plugins/docker-scout"
                     ]
                }
             ],
            "Warnings": null
         }
     }
     */
    
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
