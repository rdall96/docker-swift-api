import XCTest
@testable import DockerSwiftAPI

final class DockerTests: XCTestCase {
    
    var createdContainers: [Docker.Container] = []
    var pulledImages: [Docker.Image] = []
    
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
        pulledImages.append(image)
        return container
    }
    
    private func sleep(seconds: UInt64) async throws {
        try await Task.sleep(nanoseconds: seconds * 1000 * 1000)
    }
    
    // MARK: - Image tests
    
    func testImageModel() async throws {
        let output = """
        {"Containers":"N/A","CreatedAt":"2023-06-28 04:42:50 -0400 EDT","CreatedSince":"3 weeks ago","Digest":"003cnone003e","ID":"37f74891464b","Repository":"ubuntu","SharedSize":"N/A","Size":"69.2MB","Tag":"latest","UniqueSize":"N/A","VirtualSize":"69.19MB"}
        {"Containers":"N/A","CreatedAt":"2023-06-14 16:48:58 -0400 EDT","CreatedSince":"5 weeks ago","Digest":"003cnone003e","ID":"5053b247d78b","Repository":"alpine","SharedSize":"N/A","Size":"7.66MB","Tag":"latest","UniqueSize":"N/A","VirtualSize":"7.661MB"}
        """
        let images = Docker.Image.images(from: output)
        XCTAssertFalse(images.isEmpty)
        XCTAssertEqual(images.first, .init(name: "ubuntu", tag: .latest))
    }
    
    func testImages() async throws {
        let images: [Docker.Image] = [
            .init(name: "hello-world"),
            .init(name: "alpine"),
            .init(repository: "pihole", name: "pihole"),
            .init("oznu/homebridge")
        ]
        for image in images {
            try await Docker.pull(image: image)
            pulledImages.append(image)
        }
        for localImage in try await Docker.images {
            XCTAssertTrue(pulledImages.contains(localImage))
        }
    }
    
    // MARK: - Container tests
    
    func testContainerModel() async throws {
        let output = """
        17f85860ccb3 quizzical_hellman
        e3ad7d452464 hello
        """
        let containers = Docker.Container.containers(from: output)
        XCTAssertFalse(containers.isEmpty)
        XCTAssertEqual(containers.first, try .init("17f85860ccb3", name: "quizzical_hellman"))
    }
    
    func testCreateContainer() async throws {
        _ = try await createContainer(specs: .init(), image: .init("hello-world"))
    }
    
    func testCreateNamedContainer() async throws {
        let container = try await createContainer(
            specs: .init(
                name: "testCreateNamedContainer"
            ),
            image: .init("hello-world")
        )
        XCTAssertEqual(container.name, "testCreateNamedContainer")
    }
    
    func testRunContainer() async throws {
        let image = Docker.Image("hello-world")
        let container = try await Docker.run(image: image, with: .init(), pull: true)
        createdContainers.append(container)
        pulledImages.append(image)
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
        pulledImages.append(image)
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
        for localVolume in try await Docker.volumes {
            XCTAssertTrue(createdVolumes.contains(localVolume))
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
        self.pulledImages.append(tag)
        
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
        guard let info = try await Docker.info else {
            XCTFail("No docker info found")
            return
        }
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
