//
//  Docker.swift
//
//
//  Created by Ricky Dall'Armellina on 7/20/23.
//

import Foundation

public enum Docker {
    
    // MARK: - Images
    
    /// Download an image from a registry.
    ///
    /// - Parameters:
    ///     - image: An `Image` object containing the repository, name, and optional tag to download.
    ///
    /// - Returns: An update `Image` object representing the image that was just pulled
    @discardableResult
    public static func pull(image: Image) async throws -> Image {
        try await Shell.docker("pull \(image)")
        guard let pulledImage = try? await images.first(where: { $0.description == image.description })
        else { throw DockerError.missingImage(image) }
        return pulledImage
    }
    
    /// Download multiple images from a registry.
    /// Images will be downloaded in parallel.
    ///
    /// - Parameters:
    ///     - images: A set of `Image` objects to download.
    ///
    /// - Returns: An updated set of `Image` objects that were pulled. Note that the order is not guaranteed to persist.
    /// - Note: This call might throw if there is an error during download and any pending pulls will be discarded.
    @discardableResult
    public static func pull(images: Set<Image>) async throws -> Set<Image> {
        try await withThrowingTaskGroup(of: Image?.self) { group in
            for image in images {
                group.addTask { try await Docker.pull(image: image) }
            }
            var pulledImages = Set<Image>()
            for try await result in group.compactMap({ $0 }) {
                pulledImages.insert(result)
            }
            return pulledImages
        }
    }
    
    /// Remove an image.
    ///
    /// - Parameters:
    ///     - image: The `Image` object to remove.
    ///     - force: Force removal of the image.
    public static func remove(image: Image, force: Bool = false) async throws {
        try await Shell.docker("rmi \(force ? "--force" : "") \(image)")
    }
    
    /// List images.
    ///
    /// - Returns: A list of `Image` objects found on the current system.
    public static var images: [Image] {
        get async throws {
            Image.images(from: try await Shell.docker("images -a --digests --format \"{{ json . }}\""))
        }
    }
    
    /// Return low-level information on Docker objects.
    ///
    /// - Parameters:
    ///     - image: The `Image` object to inspect.
    ///
    /// - Returns: The image's `Image.ImageData`.
    public static func inspect(image: Image) async throws -> ImageInfo {
        let output = try await Shell.docker("inspect --format '\(ImageInfo.inspectFormat)' \(image)")
        // you can specify multiple images in the command, which will yield a list of info JSON objects, but we only need this first one here
        guard let info = try? ImageInfo(from: output) else {
            throw DockerError.invalidResponseFormat
        }
        return info
    }
    
    /// Get an image manifest, or manifest list.
    ///
    /// - Parameters:
    ///     - image: The `Image` object to inspect.
    ///
    /// - Returns: A `Manifest` object for the image.
    public static func manifest(for image: Image) async throws -> [Manifest] {
        let output = try await Shell.docker("manifest inspect --verbose \(image)")
        if let manifest = Manifest(from: output) {
            return [manifest]
        }
        if let manifests = try? Manifest.manifests(from: output) {
            return manifests
        }
        else {
            throw DockerError.invalidResponseFormat
        }
    }
    
    // MARK: - Containers
    
    /// Create a new container.
    ///
    /// - Parameters:
    ///     - specs: `ContainerSpec` object to define the properties of the container to create.
    ///     - image: Image to create the container from.
    ///     - pull: Pull the image if it's missing.
    ///
    /// - Returns: A `Container` object representing the newly created container.
    public static func create(_ specs: ContainerSpec, from image: Image, pull: Bool = true) async throws -> Container {
        if pull {
            try await self.pull(image: image)
        }
        let output = try await Shell.docker("create \(specs.options.joined(separator: " "))  --pull never \(image)")
        return try .init(output, name: specs.name, image: image)
    }
    
    /// Create a new container from the given image, and run it detached.
    ///
    /// - Parameters:
    ///     - image: Image to create the container from.
    ///     - specs: `ContainerSpec` object to define the properties of the container to create.
    ///     - pull: Pull the image if it's missing.
    ///
    /// - Returns: A `Container` object representing the newly created container.
    public static func run(image: Image, with specs: ContainerSpec, pull: Bool = true) async throws -> Container {
        if pull {
            try await self.pull(image: image)
        }
        let output = try await Shell.docker("run --detach \(specs.options.joined(separator: " ")) --pull never \(image)")
        return try .init(output, name: specs.name, image: image)
    }
    
    /// Remove a container.
    ///
    /// - Parameters:
    ///     - container: The `Container` object to remove.
    ///     - removeVolumes: Remove anonymous volumes associated with the container.
    public static func remove(container: Container, removeVolumes: Bool = false, force: Bool = false) async throws {
        try await Shell.docker("rm \(removeVolumes ? "--volumes" : "") \(force ? "--force" : "") \(container.id)")
    }
    
    /// Start a stopped container.
    ///
    /// - Parameters:
    ///     - container: the `Container` object to start.
    ///     - interactive: Attach container's STDIN.
    public static func start(_ container: Container, interactive: Bool = false) async throws {
        try await Shell.docker("start \(interactive ? "--interactive" : "") \(container.id)")
    }
    
    /// Stop a running container.
    ///
    /// - Parameters:
    ///     - container: The `Container` object to stop.
    ///     - signal: Signal to send to the container.
    ///     - timeout: Seconds to wait before killing the container.
    ///
    public static func stop(_ container: Container, signal: String? = nil, timeout: UInt? = nil) async throws {
        try await Shell.docker("stop \(signal != nil ? "--signal \(signal!)" : "") \(timeout != nil ? "--time \(timeout!)" : "") \(container.id)")
    }
    
    /// Restart a running container.
    ///
    /// - Parameters:
    ///     - container: The `Container` object to restart.
    ///     - signal: Signal to send to the container.
    ///     - timeout: Seconds to wait before killing the container.
    ///
    public static func restart(_ container: Container, signal: String? = nil, timeout: UInt? = nil) async throws {
        try await Shell.docker("restart \(signal != nil ? "--signal \(signal!)" : "") \(timeout != nil ? "--time \(timeout!)" : "") \(container.id)")
    }
    
    /// Kill a running container.
    ///
    /// - Parameters:
    ///     - container: The `Container` object to kill.
    ///     - signal: Signal to send to the container.
    ///
    public static func kill(_ container: Container, signal: String? = nil, timeout: UInt? = nil) async throws {
        try await Shell.docker("kill \(signal != nil ? "--signal \(signal!)" : "") \(container.id)")
    }
    
    /// Execute a command in a running container.
    ///
    /// - Parameters:
    ///     - command: Command to execute in the container.
    ///     - container: The `Container` object to run the command in.
    ///     - detach:
    ///     - environment: Set environment variables.
    ///     - interactive: Keep STDIN open even after detaching.
    ///     - ttry: Allocate a pseudo-TTY.
    ///     - user: Username or UID (format: "<name|uid>[:<group|gid>]").
    ///
    /// - Returns: The output of the command.
    /// - Note: If the `detach` option is used, no output will be returned.
    @discardableResult
    public static func exec(
        _ command: String,
        in container: Container,
        detach: Bool = false,
        environment: [String] = [],
        interactive: Bool = false,
        tty: Bool = false,
        user: String? = nil
    ) async throws -> String {
        var options = [String]()
        if detach {
            options.append("--detach")
        }
        for item in environment {
            options.append("--env \(item)")
        }
        if interactive {
            options.append("--interactive")
        }
        if tty {
            options.append("--tty")
        }
        if let user {
            options.append("--user \(user):\(user)")
        }
        return try await Shell.docker("exec \(options.joined(separator: " ")) \(container.id) \(command)")
    }
    
    /// List containers.
    ///
    /// - Returns: A list of `Container` objects found on the current system.
    public static var containers: [Container] {
        get async throws {
            try Container.containers(from: try await Shell.docker("ps -a --no-trunc --format \"{{.ID}} {{.Names}} {{.Image}}\""))
        }
    }
    
    /// Get the status of a container.
    ///
    /// - Parameters:
    ///     - container: The `Container` object to get the status for.
    ///
    /// - Returns: A `Container.Status` object.
    public static func status(of container: Container) async throws -> Container.Status {
        .init(from: try await Shell.docker("inspect -f '{{.State.Status}}' \(container.id)"))
    }
    
    /// Display the current resource usage statistics for a container.
    ///
    /// - Parameters:
    ///     - container: The `Container` object to get usage statistics for.
    ///
    /// - Returns: A `Container.Stats` object.
    public static func stats(of container: Container) async throws -> Container.Stats {
        let output = try await Shell.docker("stats --no-stream --format \"{{ json . }}\" \(container.id)")
        guard let data = output.data(using: .utf8) else { return .empty }
        return try JSONDecoder().decode(Container.Stats.self, from: data)
    }
    
    /// Fetch the logs of a container.
    ///
    /// - Parameters:
    ///     - container: The `Container` object to get logs for.
    ///     - tail: Optionally specify a number of log lines to keep starting from the most recent.
    ///
    /// - Returns: A list of log lines.
    public static func logs(for container: Container, tail: UInt? = nil) async throws -> [String] {
        try await Shell.docker("logs \(tail != nil ? "--tail \(tail!)" : "") \(container.id)")
            .split(separator: "\n")
            .compactMap { String($0) }
    }
    
    // MARK: - Volumes
    
    /// List volumes.
    ///
    /// - Returns: A list of `Volume` objects found on the current system.
    public static var volumes: [Volume] {
        get async throws {
            Volume.volumes(from: try await Shell.docker("volume ls --format \"{{ json . }}\""))
        }
    }
    
    /// Create a volume.
    ///
    /// - Parameters:
    ///     - name:  Name of the volume to create. If empty, a generated name will be assigned.
    ///
    /// - Returns: An object for the created `Volume`.
    public static func createVolume(name: String? = nil) async throws -> Volume {
        let output = try await Shell.docker("volume create \(name ?? "")")
        return .init(name: output)
    }
    
    /// Remove a volume. You cannot remove a volume that is in use by a container.
    ///
    /// - Parameters:
    ///     - volume: The `Volume` object to remove.
    ///
    public static func remove(volume: Volume) async throws {
        try await Shell.docker("volume rm \(volume.name)")
    }
    
    // MARK: - Build
    
    /// Start a build.
    ///
    /// - Parameters:
    ///     - path: Path to the build files.
    ///     - dockerfileName: Name of the Dockerfile (default: "Dockerfile").
    ///     - target:  Set the target build stage to build.
    ///     - tag: Optionally name and tag the image.
    ///     - buildArgs: List of build-time variables.
    ///
    /// - Returns: A `BuildResult` object with the status and output of the build task.
    public static func build(
        path: URL,
        dockerfileName: String = "Dockerfile",
        target: String? = nil,
        tag: Image? = nil,
        buildArgs: Set<BuildArg> = []
    ) async throws -> BuildResult {
        // build the command. i.e.: docker build <path.path> -f <path.path/dockerFileName> -t <name.description> --build-arg <buildArgs...>
        var options: [String] = [
            "build", path.path,
            "-f \(path.appendingPathComponent(dockerfileName).path)",
        ]
        if let target {
            options.append("--target \(target)") // Set the target build stage to build
        }
        let imageTag = tag ?? .init(name: UUID().uuidString) // create a temporary tag if one wasn't provided
        options.append("-t \(imageTag.description)")
        options.append(contentsOf: buildArgs.map({ "--build-arg \($0.description)" }))
        
        // start the build
        let command = options.joined(separator: " ")
        let result: Shell.Result = try await Shell.docker(command)
        guard result.isSuccess else {
            return .init(
                status: .failed(DockerError.systemError(
                    command: command, output: result.errorOutput
                )),
                output: result.output,
                image: nil
            )
        }
        // find the newy built image to grab the digest
        let builtImage = try await Docker.images.first(where: { $0.description == imageTag.description })
        return .init(status: .success, output: result.output, image: builtImage ?? imageTag)
    }
    
    // MARK: - Tag
    
    /// Create a tag for a source image.
    ///
    /// - Parameters:
    ///     - tag: the new `Image` name to create.
    ///     - source: The source `Image` to reference when tagging.
    ///
    public static func tag(_ tag: Image, source: Image) async throws {
        try await Shell.docker("tag \(source.description) \(tag.description)")
    }
    
    // MARK: - Registries
    
    /// Log in to a registry.
    ///
    /// - Parameters:
    ///     - server: Remote `Registry` to log into.
    ///     - username
    ///     - password
    ///
    public static func login(server: Registry = .dockerHub, username: String, password: String) async throws {
        do {
            try await Shell.docker("login \(server.rawValue) --username \(username) --password \(password)")
        }
        catch {
            throw DockerError.loginFailed(error.localizedDescription)
        }
    }
    
    /// Log out from a registry.
    ///
    /// - Parameters:
    ///     - server: `URL` of the server to close the connection for.
    ///
    public static func logout(server: URL) async throws {
        try await Shell.docker("logout \(server.absoluteString)")
    }
    
    /// Upload an image to a registry.
    ///
    /// - Parameters:
    ///     - image: The `Image` to push to the remote repository.
    ///
    /// - Returns: The `Manifest` or multiple  for the pushed image.
    @discardableResult
    public static func push(_ image: Image) async throws -> [Manifest] {
        try await Shell.docker("push \(image)")
        return try await manifest(for: image)
    }
    
    // MARK: - System
    
    /// Show the Docker version information.
    ///
    /// - Returns: String output of the Docker cli version on the current system.
    public static var version: String {
        get async throws {
            try await Shell.docker("--version")
        }
    }
    
    /// Display system-wide information.
    ///
    /// - Returns: An `Info` object representing the Docker information for the current system.
    public static var info: Info {
        get async throws {
            let output = try await Shell.docker("info --format \"{{ json . }}\"")
            guard let data = output.data(using: .utf8) else {
                throw DockerError.invalidResponseFormat
            }
            return try JSONDecoder().decode(Info.self, from: data)
        }
    }
    
    /// Clean up unused images and containers.
    ///
    /// - Parameters:
    ///     - all: If specified, this will clean even images and containers in use.
    ///
    public static func systemPrune(all: Bool = false) async throws {
        try await Shell.docker("system prune --force \(all ? "-all" : "")")
    }
}
