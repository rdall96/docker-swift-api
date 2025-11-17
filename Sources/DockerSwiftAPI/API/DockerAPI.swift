//
//  DockerAPI.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation

extension Docker {
    /// A representation of the Docker Engine API version.
    internal struct API: RawRepresentable, Equatable, Comparable {
        let rawValue: String

        init?(rawValue: String) {
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

        static func < (lhs: Docker.API, rhs: Docker.API) -> Bool {
            let lhsComponents = lhs.components
            let rhsComponents = rhs.components

            return lhsComponents[0] < rhsComponents[0]
            && lhsComponents[1] < rhsComponents[1]
        }
    }
}

// MARK: - Versions

extension Docker.API {
    /// https://docs.docker.com/reference/api/engine/version-history/#v118-api-changes
    static let v1_18 = Self(rawValue: "1.18")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v119-api-changes
    static let v1_19 = Self(rawValue: "1.19")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v120-api-changes
    static let v1_20 = Self(rawValue: "1.20")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v121-api-changes
    static let v1_21 = Self(rawValue: "1.21")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v122-api-changes
    static let v1_22 = Self(rawValue: "1.22")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v123-api-changes
    static let v1_23 = Self(rawValue: "1.23")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v124-api-changes
    static let v1_24 = Self(rawValue: "1.24")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v125-api-changes
    static let v1_25 = Self(rawValue: "1.25")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v126-api-changes
    static let v1_26 = Self(rawValue: "1.26")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v127-api-changes
    static let v1_27 = Self(rawValue: "1.27")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v128-api-changes
    static let v1_28 = Self(rawValue: "1.28")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v129-api-changes
    static let v1_29 = Self(rawValue: "1.29")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v130-api-changes
    static let v1_30 = Self(rawValue: "1.30")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v131-api-changes
    static let v1_31 = Self(rawValue: "1.31")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v132-api-changes
    static let v1_32 = Self(rawValue: "1.32")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v133-api-changes
    static let v1_33 = Self(rawValue: "1.33")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v134-api-changes
    static let v1_34 = Self(rawValue: "1.34")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v135-api-changes
    static let v1_35 = Self(rawValue: "1.35")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v136-api-changes
    static let v1_36 = Self(rawValue: "1.36")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v137-api-changes
    static let v1_37 = Self(rawValue: "1.37")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v138-api-changes
    static let v1_38 = Self(rawValue: "1.38")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v139-api-changes
    static let v1_39 = Self(rawValue: "1.39")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v140-api-changes
    static let v1_40 = Self(rawValue: "1.40")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v141-api-changes
    static let v1_41 = Self(rawValue: "1.41")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v142-api-changes
    static let v1_42 = Self(rawValue: "1.42")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v143-api-changes
    static let v1_43 = Self(rawValue: "1.43")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v144-api-changes
    static let v1_44 = Self(rawValue: "1.44")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v145-api-changes
    static let v1_45 = Self(rawValue: "1.45")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v146-api-changes
    static let v1_46 = Self(rawValue: "1.46")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v147-api-changes
    static let v1_47 = Self(rawValue: "1.47")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v148-api-changes
    static let v1_48 = Self(rawValue: "1.48")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v149-api-changes
    static let v1_49 = Self(rawValue: "1.49")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v150-api-changes
    static let v1_50 = Self(rawValue: "1.50")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v151-api-changes
    static let v1_51 = Self(rawValue: "1.51")!
    /// https://docs.docker.com/reference/api/engine/version-history/#v152-api-changes
    static let v1_52 = Self(rawValue: "1.52")!

    static let latest: Self = .v1_51
}
