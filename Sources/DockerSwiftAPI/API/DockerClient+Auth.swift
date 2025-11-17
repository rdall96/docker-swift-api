//
//  DockerClient+Auth.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation
import NIOHTTP1

/// https://docs.docker.com/reference/api/engine/version/v1.51/#tag/System/operation/SystemAuth
fileprivate struct AuthRequest: DockerRequest {
    typealias Query = Never

    struct Body: Encodable {
        let serverAddress: String
        let username: String
        let password: String

        private enum CodingKeys: String, CodingKey {
            case serverAddress = "serveraddress"
            case username
            case password
        }
    }

    let method: HTTPMethod = .POST
    let path: String = "/auth"
    let body: Body?

    init(serverAddress: String, username: String, password: String) {
        self.body = .init(
            serverAddress: serverAddress,
            username: username,
            password: password
        )
    }

    struct Response: Decodable {
        let status: String
        let token: String

        private enum CodingKeys: String, CodingKey {
            case status = "Status"
            case token = "IdentityToken"
        }
    }
}

extension DockerClient {
    /// Authenticate with a remote address.
    public func authenticate(with server: URL, username: String, password: String) async throws(DockerError) {
        let request = AuthRequest(
            serverAddress: server.absoluteString,
            username: username,
            password: password
        )
        do {
            let response = try await run(request)
            self.authToken = response.token
        }
        catch {
            switch error {
            case .failedToDecodeResponse:
                throw .invalidAutheCredentials
            default:
                logger.error("Auth request for \(username) at \(server) failed! \(error)")
                throw error
            }
        }
    }
}
