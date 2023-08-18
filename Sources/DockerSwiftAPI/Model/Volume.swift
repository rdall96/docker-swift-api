//
//  Volume.swift
//  
//
//  Created by Ricky Dall'Armellina on 8/18/23.
//

import Foundation

extension Docker {
    public struct Volume: Equatable, Hashable {
        public let name: String
        public let driver: String
        
        init(name: String, driver: String = "local") {
            self.name = name
            self.driver = driver
        }
    }
}

extension Docker.Volume: Decodable {
    /*
     {
         "Availability": "N/A",
         "Driver": "local",
         "Group": "N/A",
         "Labels": "com.docker.volume.anonymous=",
         "Links": "N/A",
         "Mountpoint": "/var/lib/docker/volumes/f84e22d8d0e2f705afb48f2989b875a5936fef001f044691ff5e548694621224/_data",
         "Name": "f84e22d8d0e2f705afb48f2989b875a5936fef001f044691ff5e548694621224",
         "Scope": "local",
         "Size": "N/A",
         "Status":"N/A"
     }
     */
    
    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case driver = "Driver"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        driver = try container.decode(String.self, forKey: .driver)
    }
}

extension Docker.Volume {
    static func volumes(from text: String) -> [Docker.Volume] {
        /*
         {"Availability":"N/A","Driver":"local","Group":"N/A","Labels":"com.docker.volume.anonymous=","Links":"N/A","Mountpoint":"/var/lib/docker/volumes/f84e22d8d0e2f705afb48f2989b875a5936fef001f044691ff5e548694621224/_data","Name":"f84e22d8d0e2f705afb48f2989b875a5936fef001f044691ff5e548694621224","Scope":"local","Size":"N/A","Status":"N/A"}
         {"Availability":"N/A","Driver":"local","Group":"N/A","Labels":"","Links":"N/A","Mountpoint":"/var/lib/docker/volumes/test_volume/_data","Name":"test_volume","Scope":"local","Size":"N/A","Status":"N/A"}
         */
        text.split(separator: "\n")
            .compactMap { line in
                guard let data = String(line).data(using: .utf8) else { return nil }
                return try? JSONDecoder().decode(Docker.Volume.self, from: data)
            }
    }
}
