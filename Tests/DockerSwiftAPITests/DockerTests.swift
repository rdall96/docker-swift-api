import XCTest
@testable import DockerSwiftAPI

final class DockerTests: XCTestCase {
    
    var createdContainers: [Docker.Container] = []
    var pulledImages: Set<Docker.Image> = []
    
    override func setUp() async throws {
        // no-op
    }
    
    override func tearDown() async throws {
        // destroy any created container and remove downloaded images
        for container in createdContainers {
            try await Docker.stop(container)
            try await Docker.remove(container: container, force: true)
        }
        for image in pulledImages {
            try await Docker.remove(image: image)
        }
    }
    
    // MARK: - Helpers
    
    private func createContainer(specs: Docker.ContainerSpec, image: Docker.Image) async throws -> Docker.Container {
        let container = try await Docker.create(specs, from: image, pull: true)
        createdContainers.append(container)
        pulledImages.insert(image)
        return container
    }
    
    private func sleep(seconds: UInt64) async throws {
        try await Task.sleep(nanoseconds: seconds * 1000 * 1000)
    }
    
    // MARK: - Image tests
    
    func testImageModel() throws {
        let output = """
        {"Containers":"N/A","CreatedAt":"2023-08-07 15:39:19 -0400 EDT","CreatedSince":"2 weeks ago","Digest":"sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a","ID":"f6648c04cd6c","Repository":"alpine","SharedSize":"N/A","Size":"7.66MB","Tag":"latest","UniqueSize":"N/A","VirtualSize":"7.66MB"}
        {"Containers":"N/A","CreatedAt":"2023-08-04 00:51:18 -0400 EDT","CreatedSince":"2 weeks ago","Digest":"sha256:ec050c32e4a6085b423d36ecd025c0d3ff00c38ab93a3d71a460ff1c44fa6d77","ID":"a2f229f811bf","Repository":"ubuntu","SharedSize":"N/A","Size":"69.2MB","Tag":"latest","UniqueSize":"N/A","VirtualSize":"69.19MB"}
        """
        let images = Docker.Image.images(from: output)
        XCTAssertFalse(images.isEmpty)
        XCTAssertEqual(images.last, .init(name: "ubuntu", tag: .latest, digest: "sha256:ec050c32e4a6085b423d36ecd025c0d3ff00c38ab93a3d71a460ff1c44fa6d77"))
    }
    
    func testImages() async throws {
        let images: Set<Docker.Image> = [
            .init(name: "hello-world"),
            .init(name: "alpine"),
            .init(repository: "pihole", name: "pihole"),
            .init("oznu/homebridge")
        ]
        pulledImages = try await Docker.pull(images: images)
        let localImages = try await Docker.images
        for image in pulledImages {
            XCTAssertTrue(localImages.contains(image))
            XCTAssertNotNil(image.digest)
        }
    }
    
    func testImageInfoModel() throws {
        let output = """
        sha256:a2f229f811bf715788cc7dae1fbe8f1d9146da54d3fbe2679ef6f230e38ea504
        [ubuntu:latest]
        2023-08-04T04:51:18.839835588Z
        arm64
        linux
        69187939
        """
        XCTAssertNotNil(try Docker.ImageInfo(from: output))
    }
    
    func testImageInfo() async throws {
        pulledImages = try await Docker.pull(images: [
            .init(name: "alpine"),
            .init(repository: "pihole", name: "pihole"),
        ])
        for image in pulledImages {
            let info = try await Docker.inspect(image: image)
            print(info)
        }
    }
    
    func testManifestModel() throws {
        let output = """
        {
        "Ref": "docker.io/rdall96/minecraft-server:latest",
        "Descriptor": {
        "digest": "sha256:58d1f169afeb7ca2f3210030fc38520abc9f51830f24dedf67527f1108ac21c0",
        "size": 1366,
        "platform": {
            "architecture": "amd64",
            "os": "linux"
        }
        },
        "SchemaV2Manifest": {
        "schemaVersion": 2,
        "config": {
            "size": 2382,
            "digest": "sha256:7b49b572a71f1a802ff86898991be2df8e0bdefaec39f43092f126f483a86570"
        },
        "layers": [
            {
                "size": 3401613,
                "digest": "sha256:7264a8db6415046d36d16ba98b79778e18accee6ffa71850405994cffa9be7de"
            },
            {
                "size": 67181352,
                "digest": "sha256:2408c49608cedb6cca7250aff6c9ccf9a32ebb12dc60f8bb2d77cb300da21ea6"
            },
            {
                "size": 47790216,
                "digest": "sha256:95db232945b09c29b11dfe4cb3c3db03d9a3e6b4e04558f25c57fdfebd5b25ff"
            },
            {
                "size": 1459,
                "digest": "sha256:51d5e4e595e4872006ae253018399a69132dc3d69f2fcd3d32f94bbcaa8f516d"
            },
            {
                "size": 32,
                "digest": "sha256:4f4fb700ef54461cfa02571ae0db9a0dc1e0cdb5577484a6d75e68dc38e8acc1"
            }
        ]
        }
        }
        """
        XCTAssertNotNil(Docker.Manifest(from: output))
    }
    
    func testInspectImage() async throws {
        let images: Set<Docker.Image> = [
            .init(name: "alpine"),
            .init(repository: "pihole", name: "pihole"),
        ]
        for image in images {
            let manifests = try await Docker.manifest(for: image)
            XCTAssertFalse(manifests.isEmpty)
        }
    }
    
    // MARK: - Container tests
    
    func testContainerModel() async throws {
        let output = """
        17f85860ccb3 quizzical_hellman pihole/pihole
        e3ad7d452464 hello ubuntu:jammy
        """
        let containers = try Docker.Container.containers(from: output)
        XCTAssertFalse(containers.isEmpty)
        XCTAssertEqual(containers.first, try .init("17f85860ccb3", name: "quizzical_hellman", image: .init("pihole/pihole")))
    }
    
    func testCreateContainer() async throws {
        let container = try await createContainer(specs: .init(), image: .init("hello-world"))
        let localContainers = try await Docker.containers
        XCTAssert(localContainers.contains(where: { $0.id == container.id }))
    }
    
    func testContainerIsAutomaticallyRemoved() async throws {
        let container = try await Docker.create(
            .init(removeWhenStopped: true),
            from: .init("hello-world"),
            pull: true
        )
        try await Docker.start(container)
        try await Task.sleep(nanoseconds: 1_000_000_000 * 1)
        let localContainers = try await Docker.containers
        XCTAssert(!localContainers.contains(where: { $0.id == container.id }))
    }
    
    func testCreateNamedContainer() async throws {
        let container = try await createContainer(
            specs: .init(
                name: "testCreateNamedContainer"
            ),
            image: .init("hello-world")
        )
        XCTAssertEqual(container.name, "testCreateNamedContainer")
        XCTAssertEqual(container.image, .init("hello-world"))
    }
    
    func testRunContainer() async throws {
        let image = Docker.Image("hello-world")
        let container = try await Docker.run(image: image, with: .init(), pull: true)
        createdContainers.append(container)
        pulledImages.insert(image)
        try await Docker.stop(container)
    }
    
    func testContainerRuntimeHappyPath() async throws {
        let container = try await createContainer(
            specs: .init(),
            image: .init(repository: "oznu", name: "homebridge")
        )
        var status = try await Docker.status(of: container)
        XCTAssert(status == .created)
        try await Docker.start(container)
        status = try await Docker.status(of: container)
        XCTAssert(status == .running)
        try await Docker.stop(container)
        status = try await Docker.status(of: container)
        XCTAssert(status == .exited)
    }
    
    func testRestartContainer() async throws {
        let container = try await createContainer(
            specs: .init(),
            image: .init(repository: "pihole", name: "pihole")
        )
        try await Docker.start(container)
        var status = try await Docker.status(of: container)
        XCTAssert(status == .running)
        try await Docker.restart(container)
        try await sleep(seconds: 5)
        status = try await Docker.status(of: container)
        XCTAssert(status == .running)
    }
    
    func testKillContainer() async throws {
        let container = try await createContainer(
            specs: .init(),
            image: .init(repository: "pihole", name: "pihole")
        )
        try await Docker.start(container)
        try await Docker.kill(container)
        let status = try await Docker.status(of: container)
        XCTAssert(status == .exited)
    }
    
    func testKillStoppedContainer() async throws {
        let container = try await createContainer(
            specs: .init(),
            image: .init(repository: "pihole", name: "pihole")
        )
        do {
            try await Docker.kill(container)
            XCTFail("Shouldn't be able to kill a stopped container")
        }
        catch is DockerError {}
        catch {
            XCTFail("Unexpected error: \(error)")
        }
        let status = try await Docker.status(of: container)
        XCTAssert(status == .created)
    }
    
    func testExecCommandInContainer() async throws {
        let container = try await createContainer(
            specs: .init(),
            image: .init(repository: "pihole", name: "pihole")
        )
        try await Docker.start(container)
        try await Docker.exec("echo Hello World!", in: container)
    }
    
    func testExecCommandInStoppedContainer() async throws {
        let container = try await createContainer(
            specs: .init(),
            image: .init(repository: "pihole", name: "pihole")
        )
        do {
            try await Docker.exec("echo Hello World!", in: container)
            XCTFail("Shouldn't be able to run commands in stopped containers")
        }
        catch is DockerError {}
        catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLogsInContainer() async throws {
        let container = try await createContainer(
            specs: .init(),
            image: .init(repository: "pihole", name: "pihole")
        )
        try await Docker.start(container)
        var logs = try await Docker.logs(for: container)
        XCTAssertGreaterThan(logs.count, 0)
        logs = try await Docker.logs(for: container, tail: 1)
        XCTAssertEqual(logs.count, 1)
    }
    
    func testLogsInStoppedContainer() async throws {
        let container = try await createContainer(
            specs: .init(),
            image: .init(repository: "pihole", name: "pihole")
        )
        let logs = try await Docker.logs(for: container)
        XCTAssertTrue(logs.isEmpty)
    }
    
    func testContainerStats() async throws {
        let container = try await createContainer(
            specs: .init(),
            image: .init(repository: "pihole", name: "pihole")
        )
        var stats = try await Docker.stats(of: container)
        XCTAssertEqual(stats.cpuPercent, 0)
        XCTAssertEqual(stats.memoryPercent, 0)
        try await Docker.start(container)
        stats = try await Docker.stats(of: container)
        XCTAssertGreaterThan(stats.cpuPercent, 0)
        XCTAssertGreaterThan(stats.memoryPercent, 0)
    }
    
    func testContainerStatsDeleted() async throws {
        let image: Docker.Image = .init(repository: "pihole", name: "pihole")
        let container = try await Docker.create(.init(), from: image, pull: true)
        pulledImages.insert(image)
        try await Docker.remove(container: container)
        do {
            _ = try await Docker.stats(of: container)
            XCTFail("Shouldn't be able to get stats for a non-existing container")
        }
        catch is DockerError {}
        catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Volmue tests
    
    func testVolumeModel() async throws {
        let output = """
        {"Availability":"N/A","Driver":"local","Group":"N/A","Labels":"com.docker.volume.anonymous=","Links":"N/A","Mountpoint":"/var/lib/docker/volumes/f84e22d8d0e2f705afb48f2989b875a5936fef001f044691ff5e548694621224/_data","Name":"f84e22d8d0e2f705afb48f2989b875a5936fef001f044691ff5e548694621224","Scope":"local","Size":"N/A","Status":"N/A"}
        {"Availability":"N/A","Driver":"local","Group":"N/A","Labels":"","Links":"N/A","Mountpoint":"/var/lib/docker/volumes/test_volume/_data","Name":"test_volume","Scope":"local","Size":"N/A","Status":"N/A"}
        """
        let volumes = Docker.Volume.volumes(from: output)
        XCTAssertFalse(volumes.isEmpty)
        XCTAssertEqual(volumes.last, .init(name: "test_volume"))
    }
    
    func testVolumes() async throws {
        let volumeNames: [String] = ["volume_1", "volume_2", "volume_3"]
        var createdVolumes = [Docker.Volume]()
        for volumeName in volumeNames {
            createdVolumes.append(try await Docker.createVolume(name: volumeName))
        }
        continueAfterFailure = true
        let localVolumes = try await Docker.volumes
        for volume in createdVolumes {
            XCTAssertTrue(localVolumes.contains(volume))
            try await Docker.remove(volume: volume)
        }
    }
    
    // MARK: - Build tests
    
    func testBuildHappyPath() async throws {
        // setup
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("docker-swift-api-tests")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let dockerFile = """
        FROM alpine:latest
        ARG PACKAGE
        RUN apk update \
            && apk add ${PACKAGE}
        """
        try dockerFile.write(
            to: tempDir.appendingPathComponent("Dockerfile"),
            atomically: true,
            encoding: .utf8
        )
        let tag = Docker.Image(name: "docker-swift-api-tests")
        
        // build
        let result = try await Docker.build(
            path: tempDir,
            tag: tag,
            buildArgs: [
                .init(key: "PACKAGE", value: "bash")
            ]
        )
        // add the create image to the tracked list
        self.pulledImages.insert(tag)
        
        print(result.output)
        switch result.status {
        case .success:
            break
        case .failed(let error):
            throw error
        }
    }
    
    // MARK: - Registry tests
    
    func testLogin() async throws {
        _ = XCTSkip("Not Implemented")
    }
    
    func testLoginInvalid() async throws {
        _ = XCTSkip("Not Implemented")
    }
    
    func testLogout() async throws {
        _ = XCTSkip("Not Implemented")
    }
    
    // MARK: - System tests
    
    func testDockerVersion() async throws {
        let version = try await Docker.version
        XCTAssertFalse(version.isEmpty)
    }
    
    func testDockerInfo() async throws {
        let info = try await Docker.info
        XCTAssertGreaterThan(info.nCpu, 0)
        XCTAssertFalse(info.architecture.isEmpty)
        XCTAssertFalse(info.serverVersion.description.isEmpty)
    }
    
    func testSystemPrune() async throws {
        _ = XCTSkip("Tested, but need to find a better way to automate it since we might end up pruning other important things on the test host")
//        // pull a bunch of images and then prune them
//        let images: Set<Docker.Image> = [
//            .init(name: "hello-world"),
//            .init(name: "alpine"),
//        ]
//        try await Docker.pull(images: images)
//        // ensure we have all images
//        var localImages = try await Docker.images
//        images.forEach {
//            XCTAssertTrue(localImages.contains($0))
//        }
//        
//        try await Docker.systemPrune()
//        
//        // ensure the images are gone
//        localImages = try await Docker.images
//        images.forEach {
//            XCTAssertFalse(localImages.contains($0))
//        }
    }
}
