//
//  DockerAPI.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

extension Docker {
    /// A representation of the Docker Engine API version.
    public struct API: RawRepresentable, Equatable, Comparable {
        public let rawValue: String

        public init?(rawValue: String) {
            let value = rawValue.filter { $0.isNumber || $0.isPunctuation }
            guard value.split(separator: ".").count == 2 else {
                return nil
            }

            self.rawValue = value
        }

        internal var version: String { "v\(rawValue)" }

        private var components: [Int] {
            rawValue.split(separator: ".").compactMap { Int($0) }
        }

        public static func < (lhs: Docker.API, rhs: Docker.API) -> Bool {
            let lhsComponents = lhs.components
            let rhsComponents = rhs.components

            return lhsComponents[0] < rhsComponents[0]
            && lhsComponents[1] < rhsComponents[1]
        }
    }
}

// MARK: - Versions

extension Docker.API {
    /// https://docs.docker.com/reference/api/engine/version-history/#v144-api-changes
    public static let v1_44 = Self(rawValue: "1.44")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v145-api-changes
    public static let v1_45 = Self(rawValue: "1.45")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v146-api-changes
    public static let v1_46 = Self(rawValue: "1.46")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v147-api-changes
    public static let v1_47 = Self(rawValue: "1.47")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v148-api-changes
    public static let v1_48 = Self(rawValue: "1.48")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v149-api-changes
    public static let v1_49 = Self(rawValue: "1.49")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v150-api-changes
    public static let v1_50 = Self(rawValue: "1.50")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v151-api-changes
    public static let v1_51 = Self(rawValue: "1.51")!

    static let latest: Self = .v1_51
}
