//
//  Errors.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation

public enum DockerError: Error {
    case unknown
    case systemError(Error)
    case requestFailed(String)
    case invalidRequest(Error)
    case failedToDecodeResponse(Error)
    case notAuthenticated
    case invalidAutheCredentials
    case imageNotFound
}
