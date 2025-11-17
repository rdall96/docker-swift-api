//
//  Platform.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker {
    public struct Platform: Equatable, Hashable, Decodable {

        public let architecture: Docker.Architecture
        public let os: String
        public let osVersion: String?
        public let variant: String?

        private enum CodingKeys: String, CodingKey {
            case architecture
            case os
            case osVersion = "os.version"
            case variant
        }
    }
}
