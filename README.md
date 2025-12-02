# DockerSwiftAPI

[![Latest Release](https://gitlab.com/rdall96/docker-swift/-/badges/release.svg)](https://gitlab.com/rdall96/docker-swift/-/releases)
[![License](https://img.shields.io/badge/LICENSE-MIT-orange)](https://gitlab.com/rdall96/docker-swift/-/blob/main/LICENSE)
![Platform](https://img.shields.io/badge/platforms-macOS%2014.0-blue)
[![CI Status](https://gitlab.com/rdall96/docker-swift/badges/main/pipeline.svg)](https://gitlab.com/rdall96/docker-swift/-/commits/main)

`DockerSwiftAPI` is a simple library to interface with the Docker CLI on your local machine.

## Add DockerSwiftAPI as a dependency to your project
The `DockerSwiftAPI` library can be added to your project project using SwiftPM. 
Add the following line to the dependencies in your `Package.swift` file:

```swift
let package = Package(
    // name, platforms, products, etc.
    dependencies: [
        .package(url: "https://gitlab.com/rdall96/docker-swift-api.git", from: "2.0.0"),
        // other dependencies
    ],
    targets: [
        .target(name: "<your-target-name>", dependencies: [
            .product(name: "DockerSwiftAPI", package: "docker-swift-api"),
        ]),
        // other targets
    ]
)
```

## Example usage

```swift
import DockerSwiftAPI

// Establish a connection with the local Docker socket
let docker = Docker(connection: .defaultSocket)

// Pull an image by tag
let image = try await docker.pullImage(with: Docker.Image.Tag(
    name: "hello-world",
    tag: "latest"
))

// Create a volume
let volume = try await docker.createVolume(id: "example_home")

// Create a container
let container = try await client.createContainer(
    name: "HelloWorld",
    config: Docker.Container.Config(
        image: image.id,
        hostConfig: .init(
            volumeMappings: [
                .volume(id: volume.id, containerPath: "/home")
            ]
        )
    )
)

// Start the container
try await docker.start(container)

// Read the container logs
let logs = try await docker.logs(for: container)

// Cleanup
try await docker.remove(container)
try await docker.remove(volume)
try await docker.remove(image)
```

## Features

These are all the Docker features supported by this library.

**System**
- Ping Docker to check if it's running.
- Get system info.

**Images**
- List images, and optionally filter by name, id, or tag.
- Pull from registry by tag or digest.
- Tag images.
- Remove images.
- Build images using context at a local directory.
- Push images to a registry.

**Volumes**
- List volumes, and optionally filter by id.
- Inspect a volume.
- Create a volume.
- Remove a volume.

> Pruning unused volumes coming to a later release.

**Containers**
- List containers. Optionally exclude stopped containers, or filter by name.
- List processes running in a container.
- Get logs for a container.
- Create containers.
- Rename containers.
- Remove containers.
- Start/stop/restart/pause/unpause containers.
- Kill containers.
- Wait for a container to stop.
