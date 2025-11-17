//
//  SystemVersion.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker {
    public struct SystemVersion: Decodable {

        public struct Platform: Decodable {
            public let name: String

            private enum CodingKeys: String, CodingKey {
                case name = "Name"
            }
        }

        public struct Component: Decodable {
            public let name: String
            public let version: Docker.Version

            private enum CodingKeys: String, CodingKey {
                case name = "Name"
                case version = "Version"
            }
        }

        public let platform: Platform
        public let components: [Component]
        public let version: Docker.Version
        public let apiVersion: Docker.Version
        public let minApiVersion: Docker.Version
        public let os: String
        public let architecture: Docker.Architecture
        public let kernelVersion: String

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
