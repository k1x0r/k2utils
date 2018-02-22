//
// ByteReader.swift
//
// Created by k1x
//

import Foundation

public protocol Reader {
    @discardableResult
    mutating func read(buffer : UnsafeMutableRawPointer, count : Int) throws -> Int
}

public extension Reader {
    
    @discardableResult
    public mutating func read<T>(to : inout T) throws -> Int {
        return try read(buffer: &to, count: MemoryLayout<T>.size)
    }
    
    @discardableResult
    public mutating func read<T>(toArray to : inout [T]) throws -> Int {
        return try read(buffer: &to, count: to.count * MemoryLayout<T>.size)
    }
    
}


public struct ByteReader : Reader {
    
    public var buffer : [Int8]
    public var position : Int = 0
    
    public init(buffer : [Int8]) {
        self.buffer = buffer
    }
    
    public mutating func read(buffer pointer: UnsafeMutableRawPointer, count : Int) throws -> Int {
        guard count + position <= buffer.count else {
            throw "Byte Buffer Overflow".error()
        }
        buffer.withUnsafeBytes { ptr -> Void in
            memcpy(pointer, ptr.baseAddress!.advanced(by: position), count)
            position += count
        }
        return count
    }
    
}

