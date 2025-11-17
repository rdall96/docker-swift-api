//
//  JSONDecoder+ByteBuffer.swift
//  docker-swift-api
//
//  Created by Ricky Dall'Armellina on 11/16/25.
//

import Foundation
import NIO
import NIOFoundationCompat

// You can technically import NIOFoundationCompat and get this method which is included in that package,
// but it's much easier to have this in a central place for the whole project to use.
extension JSONDecoder {
    internal func decode<T>(
        _ type: T.Type,
        from buffer: ByteBuffer
    ) throws -> T where T : Decodable {
        let data = Data(buffer: buffer)
        return try decode(T.self, from: data)
    }
}
