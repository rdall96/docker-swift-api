//
//  EnvironmentVariable.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker {
    public struct EnvironmentVariable: CustomStringConvertible, Sendable {
        public let key: String
        public let value: String

        public init(key: String, value: String) {
            self.key = key
            self.value = value
        }

        public var description: String { "\(key)=\(value)" }
    }

    /// A list of environment variables to set inside the container.
    public typealias Environment = [Docker.EnvironmentVariable]
}

extension Docker.EnvironmentVariable: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        let split = value.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
        self.key = String(split[0])
        self.value = split.count > 1 ? String(split[1]) : ""
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension Array where Element == Docker.EnvironmentVariable {
    public init(_ dictionary: [String : String]) where Element == Docker.EnvironmentVariable {
        self = dictionary.reduce(into: []) {
            $0.append(Docker.EnvironmentVariable(key: $1.key, value: $1.value))
        }
    }
}
