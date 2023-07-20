//
//  ShellTests.swift
//
//
//  Created by Ricky Dall'Armellina on 7/19/23.
//

import XCTest
@testable import DockerSwiftAPI

final class ShellTests: XCTestCase {
    
    // MARK: - Run
    
    func testCommandHappyPath() async throws {
        let output = try await Shell.run("echo Hello World!")
        XCTAssertEqual(output, "Hello World!")
    }
    
    func testCommandNotFound() async throws {
        do {
            try await Shell.run("wget https://www.boredapi.com/api/activity")
            XCTFail("This is not supposed to work")
        }
        catch is DockerError {}
        catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Curl
    
    private struct BoredAPIActivity: Decodable {
        let activity: String
        let type: String
    }
    
    func testCurlHappyPath() async throws {
        let activity: BoredAPIActivity = try await Shell.curl(URL(string: "https://www.boredapi.com/api/activity")!)
        XCTAssertFalse(activity.activity.isEmpty)
        XCTAssertFalse(activity.type.isEmpty)
    }
    
    func testCurlInvalidData() async throws {
        do {
            let activity: BoredAPIActivity = try await Shell.curl(URL(string: "https://www.boredapi.com/")!)
            XCTFail("This is not suposed to return an activity: \(activity.activity)")
        }
        catch is DecodingError {}
        catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Docker
    
    func testDockerHappyPath() async throws {
        let out = try await Shell.docker("--version")
        XCTAssertFalse(out.isEmpty)
    }
    
    func testDockerInvalidCommand() async throws {
        do {
            try await Shell.docker("--api-version")
            XCTFail("This command doesn't exist!")
        }
        catch is DockerError {}
        catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
