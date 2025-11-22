//
//  DockerRunner.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/22/25.
//

import Foundation
import NIOHTTP1
import AsyncHTTPClient
import Logging

internal protocol DockerRunner: Sendable {
    var logger: Logger { get }

    @discardableResult
    func response(
        for path: String,
        method: HTTPMethod,
        body: HTTPClient.Body?,
        headers: HTTPHeaders,
        timeout: Int64?
    ) async throws -> HTTPClient.Response
}

extension DockerRunner {

    func run<Request: DockerRequest>(_ request: Request, timeout: Int64?) async throws -> Request.Response where Request.Response == Void {
        let _: HTTPClient.Response = try await run(request, timeout: timeout)
        return
    }

    func run<Request: DockerRequest>(_ request: Request, timeout: Int64?) async throws -> Request.Response where Request.Response : Decodable {
        let result: HTTPClient.Response = try await run(request, timeout: timeout)
        guard let response = result.body else {
            throw DockerError.missingResponseBody
        }

        // Decode the response body
        do {
            return try JSONDecoder().decode(Request.Response.self, from: response)
        }
        catch {
            throw DockerError.failedToDecodeResponse(error)
        }
    }

    @discardableResult
    private func run<Request: DockerRequest>(_ request: Request, timeout: Int64?) async throws -> HTTPClient.Response {
        // Build the path
        let requestPath: String
        do {
            requestPath = try request.path
                // FIXME: Ensure any encoded dictionaries respect the JSON format (not the Swift one)
                // This is a bit hacky and I am sure it will break something eventually.
                // It appears that the implementation of JSONEncoder is different on Linux than it is on Apple platforms,
                // so I need to find a universal way to properly encode dictionaries into the query path.
                .replacingOccurrences(of: "=[\"", with: "={\"")
                .replacingOccurrences(of: "\"]", with: "\"}")
                .replacingOccurrences(of: "\": \"", with: "\":\"")
                .replacingOccurrences(of: "\", \"", with: "\",\"")
        }
        catch {
            logger.error("Failed to encode request path: \(error)")
            throw DockerError.invalidRequest
        }

        // Encode the body
        var requestBody: HTTPClient.Body?
        if let body = request.body {
            if let data = body as? Data {
                requestBody = .data(data)
            }
            else if let encodable = body as? any Encodable {
                do {
                    requestBody = .data(try JSONEncoder().encode(encodable))
                }
                catch {
                    logger.error("Failed to encode request body \(type(of: encodable)): \(error)")
                    throw DockerError.invalidRequest
                }
            }
            else {
                logger.error("Unsupported request body type \(type(of: body))")
                throw DockerError.invalidRequest
            }
        }

        // Setup headers
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: request.contentType.rawValue)

        if let authContext = request.authContext {
            // encode auth
            do {
                let token = try JSONEncoder().encode(authContext).base64EncodedString()
                headers.add(name: "X-Registry-Auth", value: token)
            }
            catch {
                logger.error("Failed to encode authentication context: \(error)")
                throw DockerError.invalidRequest
            }
        }

        // Run the request
        let response: HTTPClient.Response
        do {
            logger.debug("[\(request.method.rawValue)] \(requestPath)")
            response = try await self.response(
                for: requestPath,
                method: request.method.httpMethod,
                body: requestBody,
                headers: headers,
                timeout: timeout
            )
        }
        catch let error as HTTPClientError {
            if case .deadlineExceeded = error {
                throw DockerError.requestTimedOut
            }
            else {
                logger.error("Request failed: \(error)")
                throw DockerError.connectionError(error)
            }
        }
        catch {
            logger.error("Request failed: \(error)")
            throw DockerError.connectionError(error)
        }

        // Check response status
        switch response.status {
        case .ok, .created, .accepted, .noContent:
            logger.debug("Successful response: \(response.status.code)")
            return response
        case .badRequest, .forbidden, .notFound, .methodNotAllowed, .payloadTooLarge, .unsupportedMediaType:
            logger.error("Request failed! \(response.description)")
            throw DockerError.invalidRequest
        case .unauthorized:
            logger.warning("Not authenticated!")
            throw DockerError.notAuthenticated
        case .internalServerError, .notImplemented, .badGateway, .serviceUnavailable, .gatewayTimeout:
            logger.critical("\(response.description)")
            throw DockerError.connectionError(NSError(domain: "Docker", code: Int(response.status.code)))
        default:
            logger.error("[\(type(of: request))] Request failed due to an unknown error! \(response.description)")
            throw DockerError.unknown
        }
    }
}

fileprivate extension HTTPClient.Response {
    var description: String {
        if let body {
            return "\(status.description). \(String(buffer: body))"
        }
        else {
            return status.description
        }
    }
}
