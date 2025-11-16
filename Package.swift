// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "docker-swift-api",
    platforms: [
        .macOS(.v14), // this library is only available on macOS
    ],
    products: [
        .library(
            name: "DockerSwiftAPI",
            targets: ["DockerSwiftAPI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.30.0"),
    ],
    targets: [
        .target(
            name: "DockerSwiftAPI",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]
        ),
        .testTarget(
            name: "DockerSwiftAPITests",
            dependencies: ["DockerSwiftAPI"],
            resources: [
                .copy("TestBuild"),
            ]
        ),
    ]
)
