//
//  Version.swift
//  
//
//  Created by Ricky Dall'Armellina on 7/20/23.
//

import Foundation

extension Docker {
    public struct Version: Equatable, Hashable, Decodable {
        public let major: UInt
        public let minor: UInt
        public let patch: UInt?

        private init(major: UInt, minor: UInt, patch: UInt? = nil) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        private init?(from string: String) {
            let components = string.split(separator: ".")
                .compactMap { String($0) }
                .compactMap { UInt($0) }
            guard components.count >= 2 else { return nil }
            self.init(
                major: components[0],
                minor: components[1],
                patch: components.count == 3 ? components[2] : nil
            )
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let version = Docker.Version(from: string) {
                self = version
            }
            else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: [], debugDescription: "Invalid Docker version format: \(string)"
                ))
            }
        }
    }
}

extension Docker.Version: CustomStringConvertible {
    public var description: String {
        "\(major).\(minor)\(patch != nil ? ".\(patch!)" : "")"
    }
}
