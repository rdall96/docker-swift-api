//
//  DockerConnection.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/22/25.
//

import Foundation

public enum DockerConnection {
    /// Connect to a Docker socket.
    /// i.e.: `/var/run/docker.sock`
    case socket(String)

    /// Connect to a Docker host running on a specific port.
    case server(DockerHost)
}

extension DockerConnection: CustomStringConvertible {
    public var description: String {
        switch self {
        case .socket(let path): "socket@\(path)"
        case .server(let host): "host@\(host.url.absoluteString)"
        }
    }
}

// MARK: - Defaults

extension DockerConnection {

    /// The default Docker socket on Unix systems at `/var/run/docker.sock`.
    public static let defaultSocket: Self = .socket("/var/run/docker.sock")

    /// Localhost Docker instance running on port **2376**
    public static func localhost(clientKeyPEM: URL, clientCertificatePEM: URL, trustRootCertificatePEM: URL) -> Self {
        .server(DockerHost(
            url: URL(string: "https://localhost:2376")!,
            clientKeyPEM: clientKeyPEM,
            clientCertificatePEM: clientCertificatePEM,
            trustRootCertificatePEM: trustRootCertificatePEM
        ))
    }
}
