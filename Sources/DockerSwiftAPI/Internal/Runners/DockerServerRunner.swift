//
//  DockerServerRunner.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/22/25.
//

import Foundation
import NIO
import NIOSSL
import NIOHTTP1
import AsyncHTTPClient
import Logging

internal final class DockerServerRunner: DockerRunner {

    let host: DockerHost
    let client: HTTPClient
    let logger: Logger

    init(
        host: DockerHost,
        logger: Logger
    ) {
        self.host = host
        self.client = HTTPClient(eventLoopGroup: .singletonMultiThreadedEventLoopGroup)
        self.logger = logger
    }

    /// The HTTPClient must be shutdown properly to avoid crashes.
    deinit {
        do {
            try client.syncShutdown()
        }
        catch {
            logger.critical("Failed to close socket: \(error)")
        }
    }

    func response(
        for path: String,
        method: HTTPMethod,
        body: HTTPClient.Body?,
        headers: HTTPHeaders,
        timeout: Int64?
    ) async throws -> HTTPClient.Response {
        // Load TLS configuration
        let certificateChain: [NIOSSLCertificate]
        let privateKey: NIOSSLPrivateKey
        let trustRoots: NIOSSLTrustRoots
        do {
            certificateChain = try NIOSSLCertificate.fromPEMFile(host.clientCertificatePEM.path)
            privateKey = try NIOSSLPrivateKey(file: host.clientKeyPEM.path, format: .pem)
            trustRoots = NIOSSLTrustRoots.file(host.trustRootCertificatePEM.path)
        }
        catch {
            logger.critical("Failed to load TLS configuration: \(error)")
            throw DockerError.unknown
        }

        // Build a request
        let requestURL = host.url.appendingPathComponent(path)
        guard let requestURLString = requestURL.absoluteString.removingPercentEncoding else {
            logger.critical("Failed to encode request URL \(requestURL)")
            throw DockerError.unknown
        }
        let request = try HTTPClient.Request(
            url: requestURLString,
            method: method,
            headers: headers,
            body: body,
            tlsConfiguration: .makeServerConfigurationWithMTLS(
                certificateChain: certificateChain.map(NIOSSLCertificateSource.certificate),
                privateKey: .privateKey(privateKey),
                trustRoots: trustRoots
            )
        )

        // Run request
        var deadline: NIODeadline?
        if let timeout {
            deadline = .now() + .seconds(timeout)
        }
        return try await client.execute(request: request, deadline: deadline).get()
    }
}
