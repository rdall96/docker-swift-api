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

enum UnixSocketError: Error {
    case failedToEncodeRequest
    case requestFailed
    case badRequest
    case missingResponseBody
    case failedToDecodeResponse
}

internal protocol UnixSocketRequest {
    associatedtype Query: Encodable
    associatedtype Body: Encodable
    associatedtype Response

    var method: HTTPMethod { get }
    var path: String { get }
    var query: Query? { get }
    var body: Body? { get }
}

extension UnixSocketRequest {
    var query: Query? { nil }
    var body: Body? { nil }
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
    func shutdown() throws {
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
    func run(_ path: String, method: HTTPMethod = .GET, body: HTTPClient.Body? = nil) async throws -> HTTPClient.Response {
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "Host", value: hostname)

        return try await client.execute(
            on: "/\(socket)",
            method,
            path: "/\(hostname)/\(path)",
            body: body,
            headers: headers,
            logger: logger
        )
    }

    @discardableResult
    private func response<T: UnixSocketRequest>(for request: T) async throws -> HTTPClient.Response {
        // Build the endpoint
        let endpoint: String
        do {
            endpoint = try request.endpoint
        }
        catch {
            logger.error("Failed to encode \(type(of: request)) endpoint: \(error)")
            throw UnixSocketError.failedToEncodeRequest
        }

        // Encode the body
        var body: HTTPClient.Body?
        if let requestBody = request.body {
            do {
                let encoded = try JSONEncoder().encode(requestBody)
                body = .data(encoded)
            }
            catch {
                logger.error("Failed to encode \(type(of: request)) body (\(type(of: requestBody))): \(error)")
                throw UnixSocketError.failedToEncodeRequest
            }
        }

        // Run the request
        let response = try await run(endpoint, method: request.method, body: body)

        // Check response status code
        switch response.status.code {
        case 200...299:
            logger.debug("\(type(of: request)) completed successfully!")
            break
        default:
            logger.debug("\(type(of: request)) failed! [\(response.status.code)] \(response.status.description)")
            throw UnixSocketError.requestFailed
        }

        return response
    }

    func run<Request: UnixSocketRequest>(_ request: Request) async throws where Request.Response == Void {
        try await response(for: request)
    }

    func run<Request: UnixSocketRequest>(_ request: Request) async throws -> Request.Response where Request.Response : Decodable {
        let response = try await response(for: request)

        // Decode the response body
        guard let data = response.body else {
            throw UnixSocketError.missingResponseBody
        }
        do {
            return try JSONDecoder().decode(Request.Response.self, from: data)
        }
        catch {
            logger.error("Failed to decode \(Request.Response.self): \(error)")
            throw UnixSocketError.failedToDecodeResponse
        }
    }
}

fileprivate extension UnixSocketRequest {

    private var queryDictionary: [String : Any]? {
        get throws {
            guard let query else {
                return nil
            }
            let data = try JSONEncoder().encode(query)
            let json = try JSONSerialization.jsonObject(with: data)
            guard let dictionary = json as? [String : Any] else {
                throw EncodingError.invalidValue(
                    json,
                    .init(codingPath: [], debugDescription: "Query data \(type(of: query)) is not a valid JSON dictionary")
                )
            }
            return dictionary
        }
    }

    var endpoint: String {
        get throws {
            guard let queryDictionary = try queryDictionary else {
                return path
            }
            return path + "?" + queryDictionary
                .reduce(into: []) { $0.append("\($1.key)=\($1.value)") }
                .joined(separator: "&")
        }
    }
}

// HTTPClient extension to run requests on a given unix socket
fileprivate extension HTTPClient {
    func execute(
        on socket: String,
        _ method: HTTPMethod,
        path: String,
        body: Body?,
        headers: HTTPHeaders,
        deadline: NIODeadline? = nil,
        logger: Logger
    ) async throws -> Response {
        guard let url = URL(httpURLWithSocketPath: socket, uri: path) else {
            throw HTTPClientError.invalidURL
        }
        let request = try Request(url: url, method: method, headers: headers, body: body)
        return try await execute(request: request, deadline: deadline, logger: logger).get()
    }
}
