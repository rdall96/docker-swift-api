//
//  Errors.swift
//  
//
//  Created by Ricky Dall'Armellina on 7/19/23.
//

import Foundation

public enum DockerError: Error {
    case systemError(command: String, output: String)
    case dockerNotFound
    case invalidResponseFormat
    case missingContainerId
    case missingImage(Docker.Image)
    case loginFailed(String)
    
    public var errorDescription: String {
        switch self {
        case .systemError(let command, let output):
            return "An error occured when running command \"\(command)\": \(output)"
        case .dockerNotFound:
            return "Docker binary not found"
        case .invalidResponseFormat:
            return "Invalid data format in response"
        case .missingContainerId:
            return "Missing container ID"
        case .missingImage(let image):
            return "Missing image \(image)"
        case .loginFailed(_):
            return "Failed to sign into remote server"
        }
    }
}
