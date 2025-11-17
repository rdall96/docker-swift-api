//
//  DockerClient.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Foundation
import NIOHTTP1
import AsyncHTTPClient
import Logging

public final class DockerClient {
    public typealias Socket = String

    private let socket: Socket

    internal let logger: Logger

    /// Initialize a Docker client object by connecting to a Unix socket.
    public init(socket: Socket = "/var/run/docker.sock", logger: Logger? = nil) {
        self.socket = socket
        self.logger = logger ?? Logger(label: "docker-client")
    }

    // MARK: - Run

    @discardableResult
    private func result<T: DockerRequest>(for request: T) async throws -> HTTPClient.Response {
        // Build the endpoint
        let endpoint: String
        do {
            endpoint = try request.endpoint
        }
        catch {
            logger.error("Failed to encode \(type(of: request)) endpoint: \(error)")
            throw DockerError.invalidRequest(error)
        }

        // Encode the body
        let body: HTTPClient.Body?
        if let data = request.body as? Data {
            body = .data(data)
        }
        else if let encodable = request.body as? any Encodable {
            do {
                body = .data(try JSONEncoder().encode(encodable))
            }
            catch {
                logger.error("Failed to encode \(type(of: request)) body (\(type(of: encodable))): \(error)")
                throw DockerError.invalidRequest(error)
            }
        }
        else {
            body = nil
        }

        // Setup headers
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: request.contentType.rawValue)

        // Run the request
        let socket = UnixSocket(socket, hostname: request.api.version, logger: logger)
        defer { socket.shutdown() }
        do {
            return try await socket.run(
                endpoint,
                method: request.method,
                body: body,
                headers: headers
            )
        }
        catch {
            logger.error("\(type(of: request)) failed: \(error)")
            throw DockerError.systemError(error)
        }
    }

    internal func run<Request: DockerRequest>(_ request: Request) async throws where Request.Response == Void {
        try await result(for: request)
    }

    internal func run<Request: DockerRequest>(_ request: Request) async throws -> Request.Response where Request.Response : Decodable {
        let result = try await result(for: request)
        guard let data = result.body else {
            logger.error("Missing response body for \(type(of: request))")
            throw DockerError.unknown
        }

        // Decode the response body
        do {
            return try JSONDecoder().decode(Request.Response.self, from: data)
        }
        catch {
            logger.error("Failed to decode \(Request.Response.self): \(error)")
            throw DockerError.failedToDecodeResponse(error)
        }
    }
}

fileprivate extension DockerRequest {

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
            return path.trimmingCharacters(in: .init(charactersIn: "/")) + "?" + queryDictionary
                .reduce(into: []) { $0.append("\($1.key)=\($1.value)") }
                .joined(separator: "&")
        }
    }
}
