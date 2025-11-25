//
//  Helpers.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

internal enum Helpers {

    static func date(from string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }
}

internal extension Date {
    var unixTimestamp: UInt64 {
        UInt64(timeIntervalSince1970)
    }
}

internal extension UUID {
    static func requestID() -> String {
        UUID().uuidString
            .lowercased()
            .split(separator: "-")
            .map(String.init)
            .first ?? "-"
    }
}
