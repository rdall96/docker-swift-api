//
//  Labels.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

extension Docker {
    /// User-defined key/value metadata.
    public struct Labels: Equatable, Hashable {
        internal var labels: [String : String]

        public init(_ labels: [String : String] = [:]) {
            self.labels = labels
        }

        public mutating func add(name: String, value: String) {
            labels[name] = value
        }
    }
}

extension Docker.Labels: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        labels = try container.decode([String : String].self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(labels)
    }
}
