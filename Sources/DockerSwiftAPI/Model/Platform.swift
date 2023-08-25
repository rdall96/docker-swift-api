//
//  Platform.swift
//
//
//  Created by Ricky Dall'Armellina on 8/24/23.
//

import Foundation

extension Docker {
    public struct Platform: Equatable, Hashable {
        public let architecture: Architecture
        public let operatingSystem: String
    }
}

extension Docker.Platform {
    public struct Architecture: Equatable, Hashable, Decodable, RawRepresentable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static let x86 = Self(rawValue: "x86")
        public static let amd64 = Self(rawValue: "amd64")
        public static let aarch64 = Self(rawValue: "aarch64")
        public static let arm = Self(rawValue: "arm")
        public static let arm64 = Self(rawValue: "arm64")
        public static let arm64e = Self(rawValue: "arm64e")
        // more? (probably...)
    }
}

extension Docker.Platform: Decodable {
    /**
     {
         "architecture": "amd64",
         "os": "linux"
     }
     */
    private enum CodingKeys: String, CodingKey {
        case architecture
        case operatingSystem = "os"
    }
}
