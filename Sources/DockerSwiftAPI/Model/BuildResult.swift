//
//  BuildResult.swift
//  
//
//  Created by Ricky Dall'Armellina on 8/8/23.
//

import Foundation

extension Docker {
    /// Result of a Docker build.
    /// The `status` represents if the build succeeded or failed, and the `output` will contain the build log.
    public struct BuildResult {
        public let status: Status
        public let output: String
        public let image: Image?
    }
}

extension Docker.BuildResult {
    public enum Status {
        case success
        case failed(Error)
    }
}
