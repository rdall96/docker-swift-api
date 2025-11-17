//
//  Manifest.swift
//
//
//  Created by Ricky Dall'Armellina on 8/24/23.
//

import Foundation

extension Docker {
    public struct Manifest: Equatable, Hashable {
        public let ref: String
        public let descriptor: Descriptor
        public let config: Schema
        public let layers: [Schema]
    }
}

extension Docker.Manifest {
    public struct Descriptor: Equatable, Hashable {
        public let digest: String
        public let size: UInt32
        public let platform: Docker.Platform
    }
}

extension Docker.Manifest {
    public struct Schema: Equatable, Hashable {
        public let size: UInt32
        public let digest: String
    }
}

extension Docker.Manifest {
    fileprivate struct SchemaV2Manifest: Decodable {
        /**
         {
             "schemaVersion": 2,
             "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
             "config": <Schema>,
             "layers": [<Schema>]
         }
         */
        
        let version: UInt
        let config: Schema
        let layers: [Schema]
        
        private enum CodingKeys: String, CodingKey {
            case version = "schemaVersion"
            case config
            case layers
        }
    }
}

extension Docker.Manifest: Decodable {
    /**
     {
         "Ref": "docker.io/rdall96/minecraft-server:latest",
         "Descriptor": <Descriptor>,
         "Raw": <String>,
         "SchemaV2Manifest":  <SchemaV2Manifest>
     }
     */
    private enum CodingKeys: String, CodingKey {
        case ref = "Ref"
        case descriptor = "Descriptor"
        case schemaV2Manifest = "SchemaV2Manifest"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ref = try container.decode(String.self, forKey: .ref)
        descriptor = try container.decode(Descriptor.self, forKey: .descriptor)
        let schemaV2Manifest = try container.decode(SchemaV2Manifest.self, forKey: .schemaV2Manifest)
        config = schemaV2Manifest.config
        layers = schemaV2Manifest.layers
    }
}

extension Docker.Manifest.Descriptor: Decodable {
    /**
     {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "digest": "sha256:58d1f169afeb7ca2f3210030fc38520abc9f51830f24dedf67527f1108ac21c0",
         "size": 1366,
         "platform": <Platform>
     },
     */
    private enum CodingKeys: String, CodingKey {
        case digest
        case size
        case platform
    }
}

extension Docker.Manifest.Schema: Decodable {
    /**
     {
         "mediaType": "application/vnd.docker.container.image.v1+json",
         "size": 2382,
         "digest": "sha256:7b49b572a71f1a802ff86898991be2df8e0bdefaec39f43092f126f483a86570"
     }
     */
    private enum CodingKeys: String, CodingKey {
        case size
        case digest
    }
}

extension Docker.Manifest {
    init?(from json: String) {
        guard let data = json.data(using: .utf8),
              let manifest = try? JSONDecoder().decode(Docker.Manifest.self, from: data)
        else {
            return nil
        }
        self = manifest
    }
    
    static func manifests(from json: String) throws -> [Self] {
        guard let data = json.data(using: .utf8) else {
            return []
        }
        return try JSONDecoder().decode([Docker.Manifest].self, from: data)
    }
}
