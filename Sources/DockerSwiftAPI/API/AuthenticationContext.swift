//
//  AuthenticationContext.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/18/25.
//

import Foundation

/// Authentication information for a Docker registry.
public struct DockerAuthenticationContext: Encodable {

    let username: String
    let password: String
    let serverAddress: String

    /// Provide a username and password to authenticate a request with the target registry.
    /// Optionally specify the authentication server. Defaults to: `https://index.docker.io/v1/`.
    public init(
        username: String,
        password: String,
        server: URL = URL(string: "https://index.docker.io/v1/")!
    ) {
        self.username = username
        self.password = password
        self.serverAddress = server.absoluteString
    }

    private enum CodingKeys: String, CodingKey {
        case username
        case password
        case serverAddress = "serveraddress"
    }
}
