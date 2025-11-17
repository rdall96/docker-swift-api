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
    case invalidRequest(Error)
    case unsupportedRequestBody
    case requestFailed(String)
    case failedToDecodeResponse(Error)
    case imageNotFound
}
