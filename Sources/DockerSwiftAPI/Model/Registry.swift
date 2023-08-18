//
//  Registry.swift
//
//
//  Created by Ricky Dall'Armellina on 8/20/23.
//

import Foundation

extension Docker {
    public struct Registry: RawRepresentable, Equatable, Hashable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(url: URL) {
            self.rawValue = url.absoluteString
        }
        
        public static let dockerHub = Self(rawValue: "")
    }
}
