//
// ByteBuffer.swift
//
// Created by k1x
//

import Foundation

public struct ByteBuffer : WriteExtensions {
    public var buffer : [Int8]
    public var position : Int = 0
    
    public init(bufferSize : Int) {
        self.buffer = [Int8](repeating : 0, count: bufferSize)
    }
    
    @inline(__always)
    public mutating func reset() {
        position = 0
    }
    
    @inline(__always)
    public mutating func withUnsafeRemainBuffer(_ clusure: (UnsafeMutableRawPointer?, Int) throws -> Int) rethrows {
        try buffer.withUnsafeMutableBytes { buffer -> Void in
            position += try clusure(buffer.baseAddress?.advanced(by: position), buffer.count - position)
        }
    }
    
    
    @inline(__always)
    public mutating func write(buffer data : UnsafeRawPointer, count : Int) -> Int {
        buffer.withUnsafeMutableBytes { ptr in
            memcpy(ptr.baseAddress!.advanced(by: position), data, count)
            position += count
        }
        return count
    }
    
}
