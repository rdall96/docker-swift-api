//
//  Image.swift
//  
//
//  Created by Ricky Dall'Armellina on 7/19/23.
//

import Foundation

extension Docker {
    public struct Image: Equatable, Hashable {
        public typealias Name = String
        
        public let repository: String?
        public let name: Name
        public let tag: Docker.Tag
        
        public init(
            repository: String? = nil,
            name: String,
            tag: Docker.Tag = .latest
        ) {
            self.repository = repository
            self.name = name
            self.tag = tag
        }
        
        public init(_ description: String) {
            let repositoryComponents = description.split(separator: "/", maxSplits: 1)
            let repository = (repositoryComponents.count > 1) ? String(repositoryComponents[0]) : nil
            self.repository = repository
            
            let tagComponents = description.split(separator: ":", maxSplits: 1)
            let tag: Docker.Tag = (tagComponents.count == 2) ? .init(String(tagComponents[1])) : .latest
            self.tag = tag
            
            if let repository {
                name = String(tagComponents[0])
                    .replacingOccurrences(of: "\(repository)/", with: "")
            }
            else {
                name = String(tagComponents[0])
            }
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
        case repository = "Repository"
        case tag = "Tag"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let repository = try container.decode(String.self, forKey: .repository)
        let tag = try container.decode(String.self, forKey: .tag)
        self.init("\(repository):\(tag)")
    }
}

extension Docker.Image {
    /// Parse the given docker command output to load a list of images
    static func images(from text: String) -> [Docker.Image] {
        /*
         {"Containers":"N/A","CreatedAt":"2023-06-28 04:42:50 -0400 EDT","CreatedSince":"3 weeks ago","Digest":"\u003cnone\u003e","ID":"37f74891464b","Repository":"ubuntu","SharedSize":"N/A","Size":"69.2MB","Tag":"latest","UniqueSize":"N/A","VirtualSize":"69.19MB"}
         {"Containers":"N/A","CreatedAt":"2023-06-14 16:48:58 -0400 EDT","CreatedSince":"5 weeks ago","Digest":"\u003cnone\u003e","ID":"5053b247d78b","Repository":"alpine","SharedSize":"N/A","Size":"7.66MB","Tag":"latest","UniqueSize":"N/A","VirtualSize":"7.661MB"}
         */
        text.split(separator: "\n")
            .compactMap { line in
                guard let data = String(line).data(using: .utf8) else { return nil }
                return try? JSONDecoder().decode(Docker.Image.self, from: data)
            }
    }
}
