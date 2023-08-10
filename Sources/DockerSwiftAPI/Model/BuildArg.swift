//
//  BuildArg.swift
//  
//
//  Created by Ricky Dall'Armellina on 8/8/23.
//

import Foundation

extension Docker {
    
    /// Configurable build argument to pass to `docker build`. `--build-arg <key>=<value>`
    public struct BuildArg: Equatable, Hashable {
        /// Build argument key specified in the Dockerfile
        public let key: String
        /// Buidl argument value to pass to the docker build context
        public let value: String
        
        public init(key: String, value: String) {
            self.key = key
            self.value = value
        }
        
        /// A textual representation of the build argument in an environment variable format: key=value
        public var description: String {
            "\(key)=\(value)"
        }
    }
}

extension Docker.BuildArg: Identifiable {
    public var id: String { key }
}
