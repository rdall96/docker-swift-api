//
//  Tag.swift
//  
//
//  Created by Ricky Dall'Armellina on 7/19/23.
//

import Foundation

extension Docker {
    public struct Tag {
        public let name: String
        
        public init(_ name: String) {
            self.name = name
        }
    }
}

extension Docker.Tag: Hashable {}

extension Docker.Tag {
    public static var latest: Docker.Tag {
        .init("latest")
    }
}

extension Docker.Tag: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}
