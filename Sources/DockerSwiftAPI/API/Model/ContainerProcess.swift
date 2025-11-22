//
//  ContainerProcess.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker.Container {
    /// A process running in the container.
    public struct Process: Identifiable, Hashable, Sendable {
        public typealias ID = UInt

        public let user: String
        public let id: ID
        public let command: String

        // Default order:
        // - UID
        // - PID
        // - PPID
        // - C
        // - STIME
        // - TTY
        // - TIME
        // - CMD
        internal init(_ topData: [String]) throws {
            guard topData.count == 8 else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: [], debugDescription: "Missing container process data")
                )
            }

            user = topData[0]

            guard let pid = ID(topData[1]) else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: [], debugDescription: "Invalid process ID: \(topData[1])")
                )
            }
            id = pid

            command = topData[7]
        }
    }
}

extension Docker.Container.Process: CustomStringConvertible {
    public var description: String {
        "[\(id)] \(user) - \(command)"
    }
}
