//
//  DockerAPITests.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/15/25.
//

import Testing
import Foundation

// Not a testable import so we can test this as a public API
import DockerSwiftAPI

fileprivate func dockerCertURL(for name: String) -> URL {
    FileManager.default.homeDirectoryForCurrentUser
        .appending(path: "Desktop")
        .appending(path: "docker_certs")
        .appending(path: name)
}

fileprivate let localhostConnection: DockerConnection = .localhost(
    clientKeyPEM: dockerCertURL(for: "client/key.pem"),
    clientCertificatePEM: dockerCertURL(for: "client/cert.pem"),
    trustRootCertificatePEM: dockerCertURL(for: "ca/cert.pem")
)

struct DockerAPITests {

    let client: DockerClient

    init() {
        client = DockerClient(connection: .defaultSocket)
    }

    @Test
    func ping() async throws {
        #expect(await client.isAvailable)
    }

    @Test
    func systemVersion() async throws {
        let version = try await client.version
        #expect(version.platform.name.isEmpty == false)
        #expect(version.components.isEmpty == false)
        #expect(version.version.major >= 27)
        #expect(version.apiVersion.major == 1)
        #expect(version.apiVersion.minor == 51)
    }

    @Test
    func fetchImages() async throws {
        let images = try await client.images
        #expect(images.isEmpty == false)
        // there's no point in checking anything here
        // since we don't know what images might be on the host that runs the tests
    }

    @Test
    func pullImageByTag() async throws {
        let tag = Docker.Image.Tag(name: "hello-world", tag: "linux")
        try await client.pullImage(with: tag)
        _ = try #require(try await client.image(tag: tag))
    }

    @Test(.disabled("Need a way to find images by digest"))
    func pullImageByDigest() async throws {
        let digest = "53cc1017c16ab2500aa5b5367e7650dbe2f753651d88792af1b522e5af328352"
        try await client.pullImage(name: "hello-world", digest: digest)
        _ = try #require(try await client.images.first { $0.id == digest })
    }

    @Test
    func tagImage() async throws {
        let tag = Docker.Image.Tag(name: "hello-world")
        let image = try await client.pullImage(with: tag)

        let newTag = Docker.Image.Tag(name: "docker-swift-api-tests", tag: "tagImage")
        let newImage = try await client.tag(image: image, newTag)

        #expect(newImage.id == image.id)
        #expect(newImage.tags.count > image.tags.count)
    }

    @Test
    func deleteImage() async throws {
        let tag = Docker.Image.Tag(name: "hello-world")
        try await client.pullImage(with: tag)
        for image in try await client.images(withName: "hello-world") {
            try await client.remove(image, force: true)
        }
        #expect(try await client.images(withName: "hello-world").isEmpty)
    }

    @Test
    func buildImage() async throws {
        let buildDir = try #require(Bundle.module.url(forResource: "TestBuild", withExtension: nil))
        let tag = Docker.Image.Tag(name: "docker-swift-api-tests", tag: "buildImage")
        let image = try await client.buildImage(
            at: buildDir,
            ignoreFiles: [
                "ignore_this_file.txt",
            ],
            tag: tag,
            useCache: false
        )
        #expect(image.tags.contains(tag))
    }

    @Test(.disabled("Requires an image and auth credentials"))
    func pushImage() async throws {
        let image = try await client.pullImage(with: .init(name: "hello-world"))
//        client.authentication = DockerAuthenticationContext(
//            username: "",
//            password: ""
//        )
        // this should fail without auth context
        do {
            try await client.push(image)
            #expect(Bool(false), "Expected to throw")
        }
        catch {
            // no-op
        }
    }

    @Test
    func fetchVolumes() async throws {
        let volumes = try await client.volumes
        #expect(!volumes.isEmpty)
    }

    @Test
    func inspectVolume() async throws {
        // we don't know what volumes are on disk, so grab any and then re-request it
        let volume = try #require(try await client.volumes.first)
        let inspected = try await client.inspectVolume(id: volume.id)
        #expect(volume.id == inspected.id)
    }

    @Test
    func createVolume() async throws {
        let name = "docker-swift-api-tests-\(UUID().uuidString)"
        _ = try await client.createVolume(id: name)
        _ = try await client.inspectVolume(id: name)
    }

    @Test
    func removeVolume() async throws {
        let volume = try await client.createVolume(id: "docker-swift-api-tests-\(UUID().uuidString)")
        _ = try #require(try await client.volume(id: volume.id))
        try await client.remove(volume)
        #expect(try await client.volume(id: volume.id) == nil)
    }

    @Test
    func fetchContainers() async throws {
        let containers = try await client.containers()
        #expect(!containers.isEmpty)

        // check that we requested the size information
        let container = try #require(containers.first)
        #expect((container.totalSizeBytes ?? 0) > 0)

        #expect(try await client.containers(includeStopped: false).isEmpty)
    }

    @Test(.disabled("Requires container ID"))
    func fetchContainerProcesses() async throws {
        let containerID = "a4ff1b8a2852be7ebe8275e918b4e8562e5f85597f3032339c651edac9981c6d"
        let container = try #require(try await client.containers().first(where: { $0.id == containerID }))
        let processes = try await client.processes(in: container)
        #expect(!processes.isEmpty)
    }

    @Test
    func createContainer() async throws {
        try await client.pullImage(with: .init(name: "rdall96/minecraft-server"))
        let volume = try await client.createVolume()
        let config = Docker.Container.Config(
            image: "rdall96/minecraft-server",
            hostname: "docker-swift-api-tests",
            hostConfig: .init(
                volumeMappings: [
                    .volume(id: volume.id, containerPath: "/minecraft/world")
                ],
                portMappings: [
                    .init(hostPort: 7500, containerPort: 25565, type: .tcp)
                ]
            ),
            env: .init([
                "EULA": "true",
            ]),
            tty: false
        )
        try await client.createContainer(name: "DockerSwiftAPITests", config)

        // Creating a container with the same name should throw an error
        do {
            try await client.createContainer(name: "DockerSwiftAPITests", .init(image: "hello-world"))
            #expect(Bool(false), "Expected to throw")
        }
        catch {
            // no-op
        }
    }

    @Test
    func removeContainer() async throws {
        let container = try #require(try await client.container(named: "DockerSwiftAPITests"))
        try await client.remove(container, pruneUnnamedVolumes: true)
        #expect(try await client.container(named: "DockerSwiftAPITests") == nil)
    }
}
