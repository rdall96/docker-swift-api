//
//  DockerHubTests.swift
//  
//
//  Created by Ricky Dall'Armellina on 7/19/23.
//

import XCTest
@testable import DockerSwiftAPI

final class DockerHubTests: XCTestCase {
    
    override func setUp() async throws {
        // DockerHub throttles requests, so add a short wait here (5 seconds)
        try await Task.sleep(nanoseconds: 5 * 1000 * 1000)
    }
    
    // MARK: - Test repository fetch
    private static let repositories = [
        "rdall96",
        "oznu",
        "pihole",
    ]
    
    func testRepositories() async throws {
        for repository in Self.repositories {
            let response = try await DockerHub.repositories(for: repository)
            XCTAssertFalse(response.isEmpty)
            guard let testRepo = response.first else {
                fatalError()
            }
            XCTAssertEqual(testRepo.namespace, repository)
            XCTAssertGreaterThan(testRepo.pullCount, 0)
        }
    }
    
    // MARK: - Test tags fetch
    private static let images = [
        "rdall96": "minecraft-server",
        "oznu": "homebridge",
        "pihole": "pihole",
    ]
    
    func testTags() async throws {
        for repository in Self.repositories {
            let tags = try await DockerHub.tags(for: Self.images[repository]!, in: repository)
            XCTAssertFalse(tags.isEmpty)
            guard let testTag = tags.first else {
                fatalError()
            }
            XCTAssertGreaterThan(testTag.id, 0)
            XCTAssertFalse(testTag.name.isEmpty)
            XCTAssertFalse(testTag.images.isEmpty)
            for image in testTag.images {
                XCTAssertFalse(image.digest.isEmpty)
            }
        }
    }
}

