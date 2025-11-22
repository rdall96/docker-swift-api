//
//  DockerRequest.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation
import NIOHTTP1

// Expose the request methods as its own type so consumers of the library don't have to import SwiftNIO
internal enum DockerRequestMethod: String {
    case GET
    case POST
    case DELETE
}

internal enum DockerRequestContentType: String {
    case json = "application/json"
    case tar = "application/x-tar"
}

internal protocol DockerRequest {
    typealias Method = DockerRequestMethod
    associatedtype Query: Encodable
    associatedtype Body
    typealias ContentType = DockerRequestContentType
    associatedtype Response

    /// The request method
    var method: Method { get }

    /// The endpoint for this request.
    /// i.e.: `/version` or `/images/json`.
    var endpoint: String { get }

    /// Query parameters to add to the request
    var query: Query? { get }

    /// Request body payload.
    var body: Body? { get }

    /// The content type of the request payload.
    var contentType: ContentType { get }

    /// Authentication context for the request.
    var authContext: DockerAuthenticationContext? { get }
}

// MARK: - Defaults

extension DockerRequest {
    var method: Method { .GET }
    var query: Query? { nil }
    var body: Body? { nil }
    var contentType: ContentType { .json }
    var authContext: DockerAuthenticationContext? { nil }
}

// MARK: - Helpers

extension DockerRequest {

    /// Encode the query parameters into a dictionary.
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

    /// Build the endpoint for the request.
    var path: String {
        get throws {
            // If there is no query, the path is just the endpoint
            guard let queryDictionary = try queryDictionary, !queryDictionary.isEmpty else {
                return endpoint
            }
            // Add the query parameters to the path
            return endpoint.trimmingCharacters(in: .init(charactersIn: "/")) + "?" + queryDictionary
                .reduce(into: []) { $0.append("\($1.key)=\($1.value)") }
                .joined(separator: "&")
        }
    }
}

extension DockerRequestMethod {
    var httpMethod: HTTPMethod {
        switch self {
        case .GET: .GET
        case .POST: .POST
        case .DELETE: .DELETE
        }
    }
}
