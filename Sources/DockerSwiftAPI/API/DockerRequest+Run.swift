//
//  DockerRequest+Run.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation
import NIOHTTP1
import AsyncHTTPClient

extension DockerRequest {
    /// Run the request and don't return anything.
    public func start(timeout: Int64? = nil) async throws where Response == Void {
        try await run(timeout: timeout)
    }

    /// Run the request and decode the response.
    public func start(timeout: Int64? = nil) async throws -> Response where Response : Decodable {
        let result = try await run(timeout: timeout)
        guard let response = result.body else {
            logger.error("Missing response body \(Response.self)")
            throw DockerError.unknown
        }

        // Decode the response body
        do {
            return try JSONDecoder().decode(Response.self, from: response)
        }
        catch {
            logger.error("Failed to decode \(Response.self): \(error)")
            throw DockerError.failedToDecodeResponse(error)
        }
    }
}

// MARK: - Internal

internal extension DockerRequest {
    @discardableResult
    func run(on socket: Docker.Socket? = nil, timeout: Int64? = nil) async throws -> HTTPClient.Response {
        // Build the path
        let requestPath: String
        do {
            requestPath = try self.path
        }
        catch {
            logger.error("Failed to encode path: \(error)")
            throw DockerError.invalidRequest(error)
        }

        // Encode the body
        var requestBody: HTTPClient.Body?
        if let body = self.body {
            if let data = body as? Data {
                requestBody = .data(data)
            }
            else if let encodable = body as? any Encodable {
                do {
                    requestBody = .data(try JSONEncoder().encode(encodable))
                }
                catch {
                    logger.error("Failed to encode request body \(type(of: encodable)): \(error)")
                    throw DockerError.invalidRequest(error)
                }
            }
            else {
                logger.error("Unsupported request body type \(type(of: body))")
                throw DockerError.unsupportedRequestBody
            }
        }

        // Setup headers
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: self.contentType.rawValue)

        // Run the request
        let socket = DockerSocket(socket, hostname: self.api.version, logger: logger)
        defer { socket.shutdown() }
        do {
            return try await socket.run(
                requestPath,
                method: self.method.httpMethod,
                body: requestBody,
                headers: headers,
                timeout: timeout
            )
        }
        catch {
            logger.error("Request failed: \(error)")
            throw DockerError.systemError(error)
        }
    }
}

fileprivate extension DockerRequestMethod {
    var httpMethod: HTTPMethod {
        switch self {
        case .GET: .GET
        case .POST: .POST
        case .DELETE: .DELETE
        }
    }
}
