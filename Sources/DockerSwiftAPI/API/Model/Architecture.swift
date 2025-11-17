//
//  Architecture.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker {
    /// The architecture that the daemon is running on.
    public struct Architecture: RawRepresentable, Equatable, Hashable, Decodable {
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
