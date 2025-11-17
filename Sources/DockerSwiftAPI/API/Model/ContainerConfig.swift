//
//  ContainerConfig.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker.Container {
    public struct Config: Encodable {

        /// The name (or ID) of the image to use when creating the container, or which was used when the container was created.
        public let image: String

        /// The hostname to use for the container, as a valid RFC 1123 hostname.
        public let hostname: String?

        /// Container configuration that depends on the host we are running on.
        private let hostConfig: HostConfig

        /// A list of environment variables to set inside the container.
        public let env: Docker.Environment

        /// Commands run as this user inside the container. If omitted, commands run as the user specified in the image the container was started from.
        ///
        /// Can be either user-name or UID, and optional group-name or GID, separated by a colon `<user-name|UID>[<:group-name|GID>]`.
        public let user: String?

        /// Attach standard streams to a TTY, including **stdin** if it is not closed.
        public let tty: Bool

        /// Shell for when **RUN**, **CMD**, and **ENTRYPOINT** uses a shell.
        public let shell: [String]?

        /// The working directory for commands to run in.
        public let workingDirectory: String?

        /// The entry point for the container as a string or an array of strings.
        ///
        /// - NOTE: If the array consists of exactly one empty string ([""]) then the entry point is reset to system default (i.e., the entry point used by docker when there is no **ENTRYPOINT** instruction in the Dockerfile).
        public let entrypoint: [String]?

        /// Command to run specified as a string or an array of strings.
        public let command: [String]?

        /// Disable networking for the container.
        public let disableNetwork: Bool

        /// User-defined key/value metadata.
        public let labels: Docker.Labels?

        /// Whether to attach to **stdin**.
        public let attachStdIn: Bool

        /// Whether to attach to **stdout**.
        public let attachStdOut: Bool

        /// Whether to attach to **stderr**.
        public let attachStdErr: Bool

        public init(
            image: String,
            hostname: String? = nil,
            hostConfig: Docker.Container.HostConfig = .init(),
            env: Docker.Environment = [],
            user: String? = nil,
            tty: Bool = false,
            shell: [String]? = nil,
            workingDirectory: String? = nil,
            entrypoint: [String]? = nil,
            command: [String]? = nil,
            disableNetwork: Bool = false,
            labels: Docker.Labels? = nil,
            attachStdIn: Bool = false,
            attachStdOut: Bool = true,
            attachStdErr: Bool = true
        ) {
            self.image = image
            self.hostname = hostname
            self.hostConfig = hostConfig
            self.env = env
            self.user = user
            self.tty = tty
            self.shell = shell
            self.workingDirectory = workingDirectory
            self.entrypoint = entrypoint
            self.command = command
            self.disableNetwork = disableNetwork
            self.labels = labels
            self.attachStdIn = attachStdIn
            self.attachStdOut = attachStdOut
            self.attachStdErr = attachStdErr
        }

        private enum CodingKeys: String, CodingKey {
            case image = "Image"
            case hostname = "Hostname"
            case hostConfig = "HostConfig"
            case env = "Env"
            case user = "User"
            case tty = "Tty"
            case shell = "Shell"
            case workingDirectory = "WorkingDir"
            case entrypoint = "Entrypoint"
            case command = "Cmd"
            case disableNetwork = "NetworkDisabled"
            case labels = "Labels"
            case attachStdIn = "AttachStdin"
            case attachStdOut = "AttachStdout"
            case attachStdErr = "AttachStderr"
        }
    }
}
