//
//  HTTPClient+UnixSocket.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient
import Logging

extension HTTPClient {
    /// Run requests on a unix socket.
    internal func execute(
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
        logger.debug("[\(method.rawValue)] \(url.absoluteString)")
        return try await execute(request: request, deadline: deadline, logger: logger).get()
    }
}
