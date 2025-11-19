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

struct DockerAPITests {

    @Test
    func ping() async throws {
        #expect(await Docker.isAvailable)
    }

    @Test
    func systemVersion() async throws {
        let version = try await Docker.systemVersion
        #expect(version.platform.name.isEmpty == false)
        #expect(version.components.isEmpty == false)
        #expect(version.version.major >= 27)
        #expect(version.apiVersion.major == 1)
        #expect(version.apiVersion.minor == 51)
    }

    @Test
    func fetchImages() async throws {
        _ = try await DockerImagesRequest.all
        // there's no point in checking anything here
        // since we don't know what images might be on the host that runs the tests
    }

    @Test
    func pullImageByTag() async throws {
        try await DockerPullImageRequest(name: "hello-world", tag: "linux").start()
        _ = try #require(try await DockerImagesRequest.image(withName: "hello-world", tag: "linux"))
    }

    @Test(.disabled("Not Impelemented"))
    func pullImageByDigest() async throws {
        try await DockerPullImageRequest(name: "hello-world", digest: "").start()

        let image = try await DockerImagesRequest.all.first {
            $0.tags.contains("")
        }
        #expect(image != nil)
    }

    @Test
    func tagImage() async throws {
        try await DockerPullImageRequest(name: "hello-world").start()
        let image = try #require(try await DockerImagesRequest.image(withName: "hello-world"))

        try await image.tag(name: "docker-swift-api-tests", tag: "tagImage")
        let newImage = try #require(try await DockerImagesRequest.image(
            withName: "docker-swift-api-tests",
            tag: "tagImage"
        ))

        #expect(newImage.id == image.id)
    }

    @Test
    func deleteImages() async throws {
        try await DockerPullImageRequest(name: "hello-world").start()
        for image in try await DockerImagesRequest.images(withName: "hello-world") {
            try await image.remove(force: true)
        }
        #expect(try await DockerImagesRequest.images(withName: "hello-world").isEmpty)
    }

    @Test
    func buildImage() async throws {
        let buildDir = try #require(Bundle.module.url(forResource: "TestBuild", withExtension: nil))
        let request = try DockerBuildRequest(
            at: buildDir,
            ignoreFiles: [
                "ignore_this_file.txt",
            ],
            name: "docker-swift-api-tests",
            tag: "buildImage",
            useCache: false
        )
        let image = try await request.start()
        #expect(image.tags.contains("docker-swift-api-tests:buildImage"))
    }

    @Test
    func fetchVolumes() async throws {
        let volumes = try await DockerVolumesRequest.all
        #expect(!volumes.isEmpty)
    }

    @Test
    func inspectVolume() async throws {
        // we don't know what volumes are on disk, so grab any and then re-request it
        let volume = try #require(try await DockerVolumesRequest.all.first)
        _ = try await DockerInspectVolumeRequest(volumeID: volume.id).start()
    }

    @Test
    func createVolume() async throws {
        let volume = try await DockerCreateVolumeRequest(id: "docker-swift-api-tests-\(UUID().uuidString)").start()
        _ = try #require(try await DockerVolumesRequest.volume(id: volume.id))
    }

    @Test
    func removeVolume() async throws {
        let volume = try await DockerCreateVolumeRequest(id: "docker-swift-api-tests-\(UUID().uuidString)").start()
        _ = try #require(try await DockerVolumesRequest.volume(id: volume.id))

        try await volume.remove()
        #expect(try await DockerVolumesRequest.volume(id: volume.id) == nil)
    }

    @Test
    func fetchContainers() async throws {
        let containers = try await DockerContainersRequest.all
        #expect(!containers.isEmpty)

        let container = try #require(containers.first)
        #expect((container.totalSizeBytes ?? 0) > 0)

        #expect(try await DockerContainersRequest.running.isEmpty)
    }

    @Test(.disabled("Requires container ID"))
    func fetchContainerProcesses() async throws {
        let containerID = "7671c2f4f5bdcb544b554cd3762ea42081dab8727a5ddaeaaa895e1455d7bb8d"
        let processes = try await DockerContainerProcessesRequest.processes(in: containerID)
        #expect(!processes.isEmpty)
    }

    @Test
    func createContainer() async throws {
        let volume = try await DockerCreateVolumeRequest().start()
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
        _ = try await DockerCreateContainerRequest.create(name: "DockerSwiftAPITests", config)
        #expect(try await DockerContainersRequest.named("DockerSwiftAPITests") != nil)

        // Creating a container with the same name should throw an error
        do {
            try await DockerCreateContainerRequest.create(name: "DockerSwiftAPITests", .init(image: "hello-world"))
            #expect(Bool(false), "Expected to throw")
        }
        catch {
            // no-op
        }
    }

    @Test
    func removeContainer() async throws {
        let container = try #require(try await DockerContainersRequest.named("DockerSwiftAPITests"))
        try await container.remove(removeUnusedVolumes: true)
        #expect(try await DockerContainersRequest.named("DockerSwiftAPITests") == nil)
    }

    @Test(.disabled("Requires an image and auth credentials"))
    func pushImage() async throws {
        let authContext = DockerAuthenticationContext(
            username: "",
            password: ""
        )
        let pushRequest = DockerPushImageRequest(
            image: "",
            tag: "",
            auth: authContext
        )
        try await pushRequest.start()
    }
}
