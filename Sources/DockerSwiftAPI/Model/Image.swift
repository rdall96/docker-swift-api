//
//  Image.swift
//  
//
//  Created by Ricky Dall'Armellina on 7/19/23.
//

import Foundation

extension Docker {
    public struct Image: Equatable, Hashable, CustomStringConvertible {
        public typealias Name = String
        
        public let repository: String?
        public let name: Name
        public let tag: Docker.Tag
        public let digest: String?
        
        public init(
            repository: String? = nil,
            name: String,
            tag: Docker.Tag = .latest,
            digest: String? = nil
        ) {
            self.repository = repository
            self.name = name
            self.tag = tag
            self.digest = digest
        }
        
        public init(_ description: String) {
            let repositoryComponents = description.split(separator: "/", maxSplits: 1)
            let repository = (repositoryComponents.count > 1) ? String(repositoryComponents[0]) : nil
            
            let tagComponents = description.split(separator: ":", maxSplits: 1)
            let tag: Docker.Tag = (tagComponents.count == 2) ? .init(String(tagComponents[1])) : .latest
            
            let name: String
            if let repository {
                name = String(tagComponents[0])
                    .replacingOccurrences(of: "\(repository)/", with: "")
            }
            else {
                name = String(tagComponents[0])
            }
            
            self.init(repository: repository, name: name, tag: tag, digest: nil)
        }
        
        public var description: String {
            if let repository {
                return "\(repository)/\(name):\(tag.name)"
            }
            return "\(name):\(tag.name)"
        }
    }
}

extension Docker.Image: Decodable {
    /*
     {
         "Containers": "N/A",
         "CreatedAt": "2023-06-28 04:42:50 -0400 EDT",
         "CreatedSince": "3 weeks ago",
         "Digest": "\u003cnone\u003e",
         "ID": "37f74891464b",
         "Repository": "ubuntu",
         "SharedSize": "N/A",
         "Size": "69.2MB",
         "Tag": "latest",
         "UniqueSize": "N/A",
         "VirtualSize": "69.19MB"
     }
     */
    
    private enum CodingKeys: String, CodingKey {
        case info = "Repository"
        case tag = "Tag"
        case digest = "Digest"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let info = try container.decode(String.self, forKey: .info)
        let infoComponents = info.split(separator: "/").compactMap({ String($0) })
        self.init(
            repository: (infoComponents.count > 1) ? infoComponents.first : nil,
            name: infoComponents.last ?? info,
            tag: .init(try container.decode(String.self, forKey: .tag)),
            digest: try container.decode(String.self, forKey: .digest)
        )
    }
}

extension Docker.Image {
    /// Parse the given docker command output to load a list of images
    static func images(from text: String) -> [Docker.Image] {
        /*
         {"Containers":"N/A","CreatedAt":"2023-08-07 15:39:19 -0400 EDT","CreatedSince":"2 weeks ago","Digest":"sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a","ID":"f6648c04cd6c","Repository":"alpine","SharedSize":"N/A","Size":"7.66MB","Tag":"latest","UniqueSize":"N/A","VirtualSize":"7.66MB"}
         {"Containers":"N/A","CreatedAt":"2023-08-04 00:51:18 -0400 EDT","CreatedSince":"2 weeks ago","Digest":"sha256:ec050c32e4a6085b423d36ecd025c0d3ff00c38ab93a3d71a460ff1c44fa6d77","ID":"a2f229f811bf","Repository":"ubuntu","SharedSize":"N/A","Size":"69.2MB","Tag":"latest","UniqueSize":"N/A","VirtualSize":"69.19MB"}
         */
        text.split(separator: "\n")
            .compactMap { line in
                guard let data = String(line).data(using: .utf8) else { return nil }
                return try? JSONDecoder().decode(Docker.Image.self, from: data)
            }
    }
}
