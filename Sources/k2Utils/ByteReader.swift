//
// ByteReader.swift
//
// Created by k1x
//

import Foundation

public struct SocketReadResultOptions : OptionSet, MeSelf {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let endOfStream = Me(rawValue: 1 << 0)
    
}


public struct SocketReadResult : ExpressibleByIntegerLiteral {

    
    public typealias IntegerLiteralType = Int
    
    public let bytes : Int
    public let options : SocketReadResultOptions
    
    public init(integerLiteral value: Int) {
        bytes = value
        options = []
    }
    
    public init(_ bytes : Int, options : SocketReadResultOptions = []) {
        self.bytes = bytes
        self.options = options
    }
    
}

public extension Int {
    
    var emptyReadResult : SocketReadResult {
        return SocketReadResult(self)
    }
    
}

public protocol Reader {
    @discardableResult
    mutating func read(buffer : UnsafeMutableRawPointer, count : Int) throws -> SocketReadResult
}

public extension Reader {
    
    @discardableResult
    mutating func read<T>(to : inout T) throws -> SocketReadResult {
        return try read(buffer: &to, count: MemoryLayout<T>.size)
    }
    
    @discardableResult
    mutating func read<T>(toArray to : inout [T]) throws -> SocketReadResult {
        return try read(buffer: &to, count: to.count * MemoryLayout<T>.size)
    }
    
}


public class ByteReader : Reader {
    
    public var buffer : [Int8]
    public var position : Int = 0
    
    public init(buffer : [Int8]) {
        self.buffer = buffer
    }
    
    public func read(buffer pointer: UnsafeMutableRawPointer, count bytes: Int) throws -> SocketReadResult {
        guard position < buffer.count else {
            throw "Byte Buffer Overflow".error()
        }
        let count = min(bytes, buffer.count - position)
        buffer.withUnsafeBytes { ptr -> Void in
            memcpy(pointer, ptr.baseAddress!.advanced(by: position), count)
            position += count
        }
        
        var options : SocketReadResultOptions = []
        if position == buffer.count {
            options.insert(.endOfStream)
        }
        return SocketReadResult(count, options: options)
    }
    
}

/// Almost copy and paste from ByteReader, but the difference is in handling of UnsafeBytes. Create an abstraction would take more lines of code
public class DataReader : Reader {
    
    public var buffer : Data
    public var position : Int = 0
    
    public init(buffer : Data) {
        self.buffer = buffer
    }
    
    public func read(buffer pointer: UnsafeMutableRawPointer, count bytes : Int) throws -> SocketReadResult {
        guard position < buffer.count else {
            throw "Byte Buffer Overflow".error()
        }
        let count = min(bytes, buffer.count - position)
        buffer.withUnsafeBytes { ( ptr : UnsafePointer<Int8> ) -> Void in
            memcpy(pointer, ptr.advanced(by: position), count)
            position += count
        }
        
        var options : SocketReadResultOptions = []
        if position == buffer.count {
            options.insert(.endOfStream)
        }
        return SocketReadResult(count, options: options)
    }
    
}
