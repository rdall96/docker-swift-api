//
//  SystemVersion.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker {
    public struct SystemVersion: Decodable, Sendable {

        public struct Platform: Decodable, Sendable {
            public let name: String

            private enum CodingKeys: String, CodingKey {
                case name = "Name"
            }
        }

        public struct Component: Decodable, Sendable {
            public let name: String
            public let version: Docker.Version

            private enum CodingKeys: String, CodingKey {
                case name = "Name"
                case version = "Version"
            }
        }

        public let platform: Platform

        /// Information about system components
        public let components: [Component]

        /// The version of the daemon.
        public let version: Docker.Version

        /// The default (and highest) API version that is supported by the daemon.
        public let apiVersion: Docker.Version

        /// The minimum API version that is supported by the daemon.
        public let minApiVersion: Docker.Version

        /// The operating system that the daemon is running on.
        public let os: Docker.OS

        /// The architecture that the daemon is running on.
        public let architecture: Docker.Architecture

        /// The kernel version (`uname -r`) that the daemon is running on.
        /// This field is omitted when empty.
        public let kernelVersion: String?

        private enum CodingKeys: String, CodingKey {
            case platform = "Platform"
            case components = "Components"
            case version = "Version"
            case apiVersion = "ApiVersion"
            case minApiVersion = "MinAPIVersion"
            case os = "Os"
            case architecture = "Arch"
            case kernelVersion = "KernelVersion"
        }
    }
}
