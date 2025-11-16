//
//  UnixSocket.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/14/25.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient
import Logging

internal enum UnixSocketError: Error {
    case unknown
    case badRequest
    case requestFailed(reason: String)
    case serverError(reason: String)
}

internal final class UnixSocket: Sendable, CustomStringConvertible {

    let socket: String
    let hostname: String

    private let client: HTTPClient
    private let logger: Logger

    init(_ socket: String, hostname: String, logger: Logger? = nil) {
        self.socket = socket.trimmingCharacters(in: ["/"])
        self.hostname = hostname.trimmingCharacters(in: ["/"])
        self.client = HTTPClient(eventLoopGroupProvider: .singleton)
        self.logger = logger ?? Logger(label: "socket:\(socket)/\(hostname)")
    }

    /// The HTTPClient must be shutdown properly to avoid crashes.
    func shutdown() {
        do {
            try client.syncShutdown()
        }
        catch {
            logger.critical("Failed to close socket: \(error)")
        }
    }

    var description: String { "http+unix://\(socket)/\(hostname)" }

    /// Send a request to the socket.
    @discardableResult
    func run(
        _ path: String,
        method: HTTPMethod = .GET,
        body: HTTPClient.Body? = nil,
        headers: HTTPHeaders? = nil
    ) async throws(UnixSocketError) -> HTTPClient.Response {
        // add Host header
        var headers = headers ?? [:]
        headers.add(name: "Host", value: hostname)

        let response: HTTPClient.Response
        do {
            response = try await client.execute(
                on: "/\(socket)",
                method,
                path: "/\(hostname)/\(path)",
                body: body,
                headers: headers,
                logger: logger
            )
        }
        catch let error as HTTPClientError {
            logger.error("Invalid request: \(error)")
            throw .badRequest
        }
        catch {
            logger.error("Request failed: \(error)")
            throw .requestFailed(reason: error.localizedDescription)
        }

        // Check response status and return
        switch response.status {
        case .ok, .created, .accepted, .noContent:
            return response
        case .badRequest, .unauthorized, .forbidden, .notFound, .methodNotAllowed, .payloadTooLarge, .unsupportedMediaType:
            throw .requestFailed(reason: response.status.description)
        case .internalServerError, .notImplemented, .badGateway, .serviceUnavailable, .gatewayTimeout:
            throw .serverError(reason: response.status.description)
        default:
            logger.debug("[\(path)] Request failed due to an unknown error! \(response.status.description)")
            throw .unknown
        }
    }
}
