//
//  BuildArgs.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

extension Docker {
    /// Users pass these values at build-time.
    /// Docker uses the buildargs as the environment context for commands run via the Dockerfile RUN instruction, or for variable expansion in other Dockerfile instructions.
    /// - NOTE: This is not meant for passing secret values.
    public struct BuildArgs: Equatable, Hashable {
        internal var args: [String : String]

        public init(_ args: [String : String] = [:]) {
            self.args = args
        }

        public mutating func add(name: String, value: String) {
            args[name] = value
        }
    }
}

extension Docker.BuildArgs: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        args = try container.decode([String : String].self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(args)
    }
}
