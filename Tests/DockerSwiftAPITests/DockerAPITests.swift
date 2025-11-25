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

    // MARK: - Info

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

    // MARK: - Images

    @Test
    func fetchImages() async throws {
        let images = try await client.images
        #expect(images.isEmpty == false)
        // there's no point in checking anything here
        // since we don't know what images might be on the host that runs the tests
    }

    @Test
    func pullImageByTag() async throws {
        // https://hub.docker.com/layers/library/alpine/3.19/images/sha256-45470a1b6b2bb3c200494c9caff4796ad4379e8a9090d4f664cf7f6c5052cbd6
        let tag = Docker.Image.Tag(name: "alpine", tag: "3.19")
        try await client.pullImage(with: tag)
        let image = try #require(try await client.image(tag: tag))
        #expect(image.tags.contains(tag))
    }

    @Test(.disabled("Need a way to check the pulled image"))
    func pullImageByDigest() async throws {
        // https://hub.docker.com/layers/library/alpine/3.21.5/images/sha256-ceddee90ef3513446902d9f65eb3ecd41849136a936e310c7192843632cea8a9
        let digest = "5405e8f36ce1878720f71217d664aa3dea32e5e5df11acbf07fc78ef5661465b"
        try await client.pullImage(name: "alpine", digest: digest)
        print(try await client.images(name: "alpine").map(\.digests))
        _ = try #require(try await client.images(name: "alpine").first {
            $0.digests.contains("sha256:\(digest)")
        })
    }

    @Test
    func tagImage() async throws {
        let tag = Docker.Image.Tag(name: "hello-world")
        let image = try await client.pullImage(with: tag)

        let newTag = Docker.Image.Tag(name: "docker-swift-api-tests", tag: "tagImage")
        let newImage = try await client.tag(image, tag: newTag)

        #expect(newImage.id == image.id)
        #expect(newImage.tags.count > image.tags.count)
    }

    @Test
    func deleteImage() async throws {
        let tag = Docker.Image.Tag(name: "hello-world")
        try await client.pullImage(with: tag)
        for image in try await client.images(name: "hello-world") {
            try await client.remove(image, force: true)
        }
        #expect(try await client.images(name: "hello-world").isEmpty)
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

    @Test(.disabled("Need somewhere to push to"))
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

    // MARK: - Volumes

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
        _ = try #require(try await client.volume(id: name))
        _ = try await client.inspectVolume(id: name)
    }

    @Test
    func removeVolume() async throws {
        let volume = try await client.createVolume(id: "docker-swift-api-tests-\(UUID().uuidString)")
        _ = try #require(try await client.volume(id: volume.id))
        try await client.remove(volume)
        #expect(try await client.volume(id: volume.id) == nil)
    }

    // MARK: - Containers

    @Test
    func fetchContainers() async throws {
        let containers = try await client.containers()
        #expect(containers.isEmpty == false)

        // check that we requested the size information
        let container = try #require(containers.first)
        #expect((container.totalSizeBytes ?? 0) > 0)

        #expect(try await client.containers(includeStopped: false).isEmpty)
    }

    @Test
    func createContainer() async throws {
        let image = try await client.pullImage(with: .init(name: "rdall96/minecraft-server"))
        let volume = try await client.createVolume()
        let config = Docker.Container.Config(
            image: image.id,
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
            tty: true
        )
        let container = try await client.createContainer(name: "DockerSwiftAPITests", config: config)

        // Creating a container with the same name should throw an error
        do {
            try await client.createContainer(
                name: "DockerSwiftAPITests",
                config: .init(image: "hello-world")
            )
            #expect(Bool(false), "Expected to throw")
        }
        catch {
            // no-op
        }

        try await client.remove(container, force: true)
    }

    @Test
    func renameContainer() async throws {
        let image = try await client.pullImage(with: .init(name: "hello-world"))
        let config = Docker.Container.Config(image: image.id)
        var container = try await client.createContainer(config: config)
        #expect(!container.names.contains(where: { $0.contains("/DockerSwiftAPITests") }))

        try await client.renameContainer(container, name: "DockerSwiftAPITests")
        container = try #require(try await client.container(name: "DockerSwiftAPITests"))
        #expect(container.names.contains(where: { $0.contains("/DockerSwiftAPITests") }))
    }

    @Test
    func removeContainer() async throws {
        let image = try await client.pullImage(with: .init(name: "hello-world"))
        let config = Docker.Container.Config(image: image.id)
        let container = try await client.createContainer(config: config)
        try await client.remove(container, pruneUnnamedVolumes: true)
        #expect(try await client.container(name: try #require(container.names.first)) == nil)
    }

    @Test
    func containerRun() async throws {
        let image = try await client.pullImage(with: .init(name: "rdall96/minecraft-server"))
        let config = Docker.Container.Config(
            image: image.id,
            env: .init([
                "EULA": "true",
            ])
        )
        let container = try await client.createContainer(config: config)

        // Start
        try await client.start(container)
        try await Task.sleep(for: .seconds(1))

        // Stop
        try await client.stop(container)
        try await Task.sleep(for: .milliseconds(250))
    }

    @Test
    func containerLogs() async throws {
        let image = try await client.pullImage(with: .init(name: "hello-world"))
        let container = try await client.createContainer(config: .init(
            image: image.id,
            hostConfig: .init(
                restartPolicy: .never,
                logType: .jsonFile
            ),
            tty: true
        ))
        try await client.start(container)

        let logs = try await client.logs(for: container)
        print(logs)
        #expect(logs.isEmpty == false)
        #expect(logs.contains("Hello from Docker!"))
    }

    @Test
    func containerProcesses() async throws {
        let image = try await client.pullImage(with: .init(name: "rdall96/minecraft-server"))
        let config = Docker.Container.Config(
            image: image.id,
            env: .init([
                "EULA": "true",
            ])
        )
        let container = try await client.createContainer(config: config)
        try await client.start(container)
        try await Task.sleep(for: .seconds(2))

        let processes = try await client.processes(in: container)
        #expect(!processes.isEmpty)
    }
}
