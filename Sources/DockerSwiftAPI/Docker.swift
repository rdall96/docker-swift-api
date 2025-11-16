//
//  Docker.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

// Namespace to group all Docker types
public enum Docker {

    /// A representation of the Docker Engine API version.
    public struct API: RawRepresentable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(_ version: String) {
            let value = version.filter { "0123456789.".contains($0) }
            self.init(rawValue: "v\(value)")
        }

        public static let v1_51 = API(rawValue: "v1.51")
        public static let latest: API = .v1_51
    }
}
