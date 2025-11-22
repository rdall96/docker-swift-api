//
//  OS.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker {
    /// The operating system that the daemon is running on.
    /// i.e.: `linux` or `windows`.
    public struct OS: RawRepresentable, Codable, Sendable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let linux = OS(rawValue: "linux")
        public static let windows = OS(rawValue: "windows")
    }
}
