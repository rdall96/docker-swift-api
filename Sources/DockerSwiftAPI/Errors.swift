//
//  Errors.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation
import NIOHTTP1

public enum DockerError: Error {
    case unknown
    case systemError(Error)
    case requestFailed(HTTPResponseStatus)
    case invalidRequest(Error)
    case failedToDecodeResponse(Error)
    case imageNotFound
}
