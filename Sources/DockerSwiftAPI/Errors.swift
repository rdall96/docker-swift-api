//
//  Errors.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

public enum DockerError: Error {
    case unknown

    case invalidRequest
    case missingResponseBody
    case failedToDecodeResponse(Error)
    case connectionError(Error)
    case requestTimedOut
    case notAuthenticated

    case imageNotFound
    case buildFailed(Error)
    case invalidTag
    case containerAlreadyExists
    case containerNotFound
}
