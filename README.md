# DockerSwiftAPI

[![Latest Release](https://gitlab.com/rdall96/docker-swift/-/badges/release.svg)](https://gitlab.com/rdall96/docker-swift/-/releases)
[![License](https://img.shields.io/badge/LICENSE-MIT-green)](https://gitlab.com/rdall96/docker-swift/-/blob/main/LICENSE)
![Platform](https://img.shields.io/badge/platforms-macOS%2012.0-orange)
[![CI Status](https://gitlab.com/rdall96/docker-swift/badges/main/pipeline.svg)](https://gitlab.com/rdall96/docker-swift/-/commits/main)

`DockerSwiftAPI` is a simple library to interface with the Docker CLI on your local machine.

## Usage
```swift
import DockerSwiftAPI

// Pull an image
let image = Docker.Image(
    repository: "pihole",
    name: "pihole",
    tag: .latest
)
try await Docker.pull(image: image)

// List local images
let images = try await Docker.images

// Run a container
let containerSpec = Docker.ContainerSpec()
let container = try await Docker.run(
    image: image,
    with: containerSpec
)
```

[The complete API documentation can be found here](https://gitlab.com/rdall96/docker-swift/-/wikis/docker-swift-api-v1).

## Add DockerSwiftAPI as a dependency to your project
The `DockerSwiftAPI` library can be added to your project project using SwiftPM. 
Add the following line to the dependencies in your `Package.swift` file:

```swift
let package = Package(
    // name, platforms, products, etc.
    dependencies: [
        .package(url: "https://gitlab.com/rdall96/docker-swift-api", from: "1.0.0"),
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
