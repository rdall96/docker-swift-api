//
//  Container.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/17/25.
//

import Foundation

extension Docker {
    public struct Container: Equatable, Hashable, Identifiable, Decodable {
        public typealias ID = String

        /// The state of a container.
        public enum State: String, Decodable {
            case created
            case running
            case paused
            case restarting
            case exited
            case removing
            case dead
        }

        /// A mount used by a container.
        public struct Mount: Equatable, Hashable, Decodable {

            /// The mount type.
            public enum MountType: String, Decodable {
                /// A mount of a file or directory from the host into the container.
                case bind
                /// A docker volume with the given Name.
                case volume
                /// A docker image.
                case image
                /// A tmpfs.
                case tmpfs
                /// A named pipe from the host into the container.
                case npipe
                /// A Swarm cluster volume.
                case cluster
            }

            /// The mount type.
            public let type: MountType

            /// Name reference to the underlying data.
            /// i.e.: the volume name.
            public let name: String?

            /// Source location of the mount.
            ///
            /// - For volumes, this contains the storage location of the volume (within /var/lib/docker/volumes/).
            /// - For bind-mounts, and npipe, this contains the source (host) part of the bind-mount.
            /// - For tmpfs mount points, this field is empty.
            public let source: String

            /// Destination is the path relative to the container root (`/`) where the Source is mounted inside the container.
            public let destination: String

            /// Driver is the volume driver used to create the volume (if it is a volume).
            public let driver: String?

            /// Mode is a comma separated list of options supplied by the user when creating the bind/volume mount.
            ///
            /// The default is platform-specific (`z` on Linux, empty on Windows).
            public let mode: String

            /// Whether the mount is mounted writable (read-write).
            public let writable: Bool

            private enum CodingKeys: String, CodingKey {
                case type = "Type"
                case name = "Name"
                case source = "Source"
                case destination = "Destination"
                case driver = "Driver"
                case mode = "Mode"
                case writable = "RW"
            }
        }

        /// The ID of this container as a 128-bit (64-character) hexadecimal string (32 bytes).
        public let id: String

        /// The names associated with this container. Most containers have a single name, but when using legacy "links", the container can have multiple names.
        ///
        /// - NOTE: For historic reasons, names are prefixed with a forward-slash (`/`).
        public let names: [String]

        /// The ID (digest) of the image that this container was created from.
        public let imageID: Docker.Image.ID

        /// Command to run when starting the container.
        public let command: String

        /// Date and time at which the container was created.
        public let createdAt: Date

        /// Port-mappings for the container.
        public let ports: [Docker.Container.PortMap]

        /// The size of files that have been created or changed by this container.
        public let sizeBytes: Int64?

        /// The total size of all files in the read-only layers from the image that the container uses.
        /// These layers can be shared between containers.
        public let totalSizeBytes: Int64?

        /// User-defined key/value metadata.
        public let labels: Docker.Labels?

        /// The state of this container.
        public let state: State

        /// Additional human-readable status of this container (i.e.: `Exit 0`)
        public let statusDescription: String

        /// List of mounts used by the container.
        public let mounts: [Mount]

        private enum CodingKeys: String, CodingKey {
            case id = "Id"
            case names = "Names"
            case imageID = "ImageID"
            case command = "Command"
            case createdAt = "Created"
            case ports = "Ports"
            case sizeBytes = "SizeRw"
            case totalSizeBytes = "SizeRootFs"
            case labels = "Labels"
            case state = "State"
            case statusDescription = "Status"
            case mounts = "Mounts"
        }
    }
}
