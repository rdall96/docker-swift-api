// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public enum Docker {
    
    // MARK: - Images
    
    /// Download an image from a registry
    public static func pull(image: Image) async throws {
        try await Shell.docker("pull \(image.description)")
    }
    
    /// Download multiple images from a registry
    public static func pull(images: Set<Image>) async throws {
        for image in images {
            try await Docker.pull(image: image)
        }
    }
    
    /// Remove an image
    public static func remove(image: Image, force: Bool = false) async throws {
        try await Shell.docker("rmi \(force ? "--force" : "") \(image.description)")
    }
    
    /// List images
    public static var images: [Image] {
        get async throws {
            Image.images(from: try await Shell.docker("images -a --format \"{{ json . }}\""))
        }
    }
    
    // MARK: - Containers
    
    /// Create a new container
    public static func create(_ specs: ContainerSpec, from image: Image) async throws -> Container {
        let output = try await Shell.docker("create \(specs.options.joined(separator: " ")) \(image.description)")
        return try .init(output, name: specs.name)
    }
    
    /// Create and run a new container from an image
    public static func run(image: Image, with specs: ContainerSpec, detached: Bool = false) async throws -> Container {
        let output = try await Shell.docker("run \(detached ? "--detach" : "") \(specs.options.joined(separator: " ")) \(image.description)")
        return try .init(output, name: specs.name)
    }
    
    /// Remove a container
    public static func remove(container: Container, removeVolumes: Bool = false, force: Bool = false) async throws {
        try await Shell.docker("rm \(removeVolumes ? "--volumes" : "") \(force ? "--force" : "") \(container.id)")
    }
    
    /// Start a stopped container
    public static func start(_ container: Container, interactive: Bool = false) async throws {
        try await Shell.docker("start \(interactive ? "--interactive" : "") \(container.id)")
    }
    
    /// Stop a running container
    public static func stop(_ container: Container, signal: String? = nil, timeout: UInt? = nil) async throws {
        try await Shell.docker("stop \(signal != nil ? "--signal \(signal!)" : "") \(timeout != nil ? "--time \(timeout!)" : "") \(container.id)")
    }
    
    /// Restart a running container
    public static func restart(_ container: Container, signal: String? = nil, timeout: UInt? = nil) async throws {
        try await Shell.docker("restart \(signal != nil ? "--signal \(signal!)" : "") \(timeout != nil ? "--time \(timeout!)" : "") \(container.id)")
    }
    
    /// Kill a running container
    public static func kill(_ container: Container, signal: String? = nil, timeout: UInt? = nil) async throws {
        try await Shell.docker("kill \(signal != nil ? "--signal \(signal!)" : "") \(container.id)")
    }
    
    /// Execute a command in a running container
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
    
    /// List containers
    public static var containers: [Container] {
        get async throws {
            Container.containers(from: try await Shell.docker("ps -a --format \"{{.ID}} {{.Names}}\""))
        }
    }
    
    /// Get the status of a container
    public static func status(of container: Container) async throws -> Container.Status {
        .init(from: try await Shell.docker("inspect -f '{{.State.Status}}' \(container.id)"))
    }
    
    /// Display the current resource usage statistics for a container
    public static func stats(of container: Container) async throws -> Container.Stats {
        let output = try await Shell.docker("stats --no-stream --format \"{{ json . }}\" \(container.id)")
        guard let data = output.data(using: .utf8) else { return .empty }
        return try JSONDecoder().decode(Container.Stats.self, from: data)
    }
    
    /// Fetch the logs of a container
    public static func logs(for container: Container, tail: UInt? = nil) async throws -> [String] {
        return try await Shell.docker("logs \(tail != nil ? "--tail \(tail!)" : "") \(container.id)")
            .split(separator: "\n")
            .compactMap { String($0) }
    }
    
    // MARK: - Registries
    
    /// Log in to a registry
    public static func login(server: URL, username: String, password: String) async throws {
        do {
            try await Shell.docker("login \(server.absoluteString) --username \(username) --password \(password)")
        }
        catch {
            throw DockerError.loginFailed(error.localizedDescription)
        }
    }
    
    /// Log out from a registry
    public static func logout(server: URL) async throws {
        try await Shell.docker("logout \(server.absoluteString)")
    }
    
    // MARK: - System
    
    /// Show the Docker version information
    public static var version: String {
        get async throws {
            try await Shell.docker("--version")
        }
    }
    
    /// Display system-wide information
    public static var info: Info? {
        get async throws {
            let output = try await Shell.docker("info --format \"{{ json . }}\"")
            guard let data = output.data(using: .utf8) else { return nil }
            return try JSONDecoder().decode(Info.self, from: data)
        }
    }
    
    /// Clean up unused images and containers. If `all` is specified, this will clean even images and containers in use
    public static func systemPrune(all: Bool = false) async throws {
        try await Shell.docker("system prune --force \(all ? "-all" : "")")
    }
}
