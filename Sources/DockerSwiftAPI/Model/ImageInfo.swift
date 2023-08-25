//
//  ImageInfo.swift
//
//
//  Created by Ricky Dall'Armellina on 8/24/23.
//

import Foundation

extension Docker {
    public struct ImageInfo: Equatable, Hashable {
        public let id: String
        public let tags: [Image]
        public let created: Date
        public let architecture: Platform.Architecture
        public let operatingSystem: String
        public let size: UInt32
        
        static let inspectFormat = """
        {{ .Id }}
        {{ .RepoTags }}
        {{ .Created }}
        {{ .Architecture }}
        {{ .Os }}
        {{ .Size }}
        """
    }
}

extension Docker.ImageInfo {
    /**
     sha256:f6648c04cd6ce95adc05b3aa55265007b95d64d508755be8506cee652792952c
     [alpine:latest]
     2023-08-07T19:39:19.604550822Z
     20.10.23
     arm64
     linux
     7660183
     */
    
    init?(from json: String) throws {
        let components = json.split(separator: "\n").compactMap {
            String($0).trimmingCharacters(in:.whitespacesAndNewlines)
        }
        guard components.count == 6 else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Expected 6 inspect properties, found \(components.count)"))
        }
        id = components[0]
        tags = components[1]
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .split(separator: ",")
            .compactMap({ String($0).trimmingCharacters(in: .whitespacesAndNewlines )})
            .compactMap({ Docker.Image($0) })
        guard let date = Date(from: components[2]) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid date format: \(components[2])"))
        }
        created = date
        architecture = .init(rawValue: components[3])
        operatingSystem = components[4]
        size = UInt32(components[5]) ?? .zero
    }
}

extension Date {
    fileprivate init?(from string: String) {
        // i.e.: `2023-08-04T04:51:18.839835588Z`
        let dateString = string
            .replacingOccurrences(of: "T", with: " ") // space out the date and time
            .split(separator: ".") // ignore milliseconds
            .first ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: String(dateString)) else {
            return nil
        }
        self = date
    }
}
