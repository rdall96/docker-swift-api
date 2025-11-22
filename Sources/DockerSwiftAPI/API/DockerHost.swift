//
//  DockerHost.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/22/25.
//

import Foundation

public struct DockerHost: Sendable {

    /// The URL where to find the Docker host.
    /// i.e.: `https://localhost:2376`
    public let url: URL

    /// Path on disk to the client key to use for communicating with the Docker server.
    public let clientKeyPEM: URL

    /// Path on disk to the client SSL certificate to use for communicating with the Docker server.
    public let clientCertificatePEM: URL

    /// Path on disk to the trust root certificate to use for communicating with the Docker server.
    public let trustRootCertificatePEM: URL

    public init(
        url: URL,
        clientKeyPEM: URL,
        clientCertificatePEM: URL,
        trustRootCertificatePEM: URL
    ) {
        // TODO: Add validation to the paths
        self.url = url
        self.clientKeyPEM = clientKeyPEM
        self.clientCertificatePEM = clientCertificatePEM
        self.trustRootCertificatePEM = trustRootCertificatePEM
    }
}
