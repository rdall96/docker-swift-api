//
//  BuildArgs.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

extension Docker {
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
