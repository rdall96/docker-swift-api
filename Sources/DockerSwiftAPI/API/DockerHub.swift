//
//  DockerHub.swift
//  
//
//  Created by Ricky Dall'Armellina on 7/19/23.
//

import Foundation
import AsyncHTTPClient

// MARK: - API Endpoints

public enum DockerHub {
    public typealias Namespace = String
    
    private static let apiUrl: URL = URL(string: "https://hub.docker.com/v2/")!
    
    private static func repositoriesUrl(for namespace: Namespace) -> URL {
        Self.apiUrl
            .appendingPathComponent("namespaces")
            .appendingPathComponent(namespace)
            .appendingPathComponent("repositories")
    }
    
    private static func tagsUrl(for repositoryName: Repository.Name, in namespace: Namespace) -> URL {
        Self.repositoriesUrl(for: namespace)
            .appendingPathComponent(repositoryName)
            .appendingPathComponent("tags")
    }
}

// MARK: - Requests

fileprivate struct PagedResponse<T: Decodable>: Decodable {
    let count: UInt
    let next: URL?
    let previous: URL?
    let results: [T]
}

fileprivate struct DockerHubRequest {
    let url: URL

    func get<T: Decodable>() async throws -> T {
        let client = HTTPClient(eventLoopGroupProvider: .singleton)
        let response = try await client.execute(.GET, url: url.absoluteString).get()
        guard response.status == .ok, let data = response.body else {
            try? await client.shutdown()
            throw DockerError.requestFailed(response.status)
        }
        let decoded = try JSONDecoder().decode(T.self, from: data)
        try? await client.shutdown()
        return decoded
    }
}

extension DockerHub {
    
    private static func pagedResults<T:Decodable>(for url: URL) async throws -> Set<T> {
        var data = Set<T>()
        var url: URL? = url
        while url != nil {
            guard let unwrappedUrl = url else { break }
            let request = DockerHubRequest(url: unwrappedUrl)
            let response: PagedResponse<T> = try await request.get()
            url = response.next
            data.formUnion(response.results)
        }
        return data
    }
    
    /// List the available images for the given DockerHub repository
    public static func repositories(for namespace: Namespace) async throws -> Set<Repository> {
        try await Self.pagedResults(for: Self.repositoriesUrl(for: namespace))
    }
    
    /// List all the available tags for a given repository
    public static func tags(for repository: Repository) async throws -> Set<Tag> {
        try await Self.pagedResults(for: Self.tagsUrl(for: repository.name, in: repository.namespace))
    }
    
    /// List all the available tags for a given image name in the namespace
    public static func tags(for repositoryName: Repository.Name, in namespace: Namespace) async throws -> Set<Tag> {
        try await Self.pagedResults(for: Self.tagsUrl(for: repositoryName, in: namespace))
    }
}

// MARK: - Model

extension DockerHub {
    
    public struct Repository: Decodable, Hashable {
        public typealias Name = String
        
        public let name: Name
        public let namespace: Namespace
        public let description: String
        public let isPrivate: Bool
        public let starCount: UInt
        public let pullCount: UInt
        
        private enum CodingKeys: String, CodingKey {
            case name
            case namespace
            case description
            case isPrivate = "is_private"
            case starCount = "star_count"
            case pullCount = "pull_count"
        }
    }
    
    public struct Tag: Decodable, Hashable {
        public typealias Name = String
        
        public let id: UInt
        public let name: Name
        public let images: [Image]
    }
    
    public struct Image: Decodable, Hashable {
        public let architecture: Docker.Platform.Architecture
        public let features: String
        public let digest: String
        public let os: String
        public let size: UInt
    }
}
