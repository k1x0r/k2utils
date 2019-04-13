//
// Pointers.swift
//
// Created by k1x
//

import Foundation

public protocol Pointer : This {
    func advanced(by : Int) -> Self
    func unsafePointer<T>(with: T.Type) -> UnsafePointer<T>
}

public protocol MutablePointer : Pointer {
    static func allocate(capacity: Int) -> Self
    func unsafeMutablePointer<T>(with: T.Type) -> UnsafeMutablePointer<T>

}

public protocol BufferPointer : This {
    associatedtype PointerType : Pointer
    var count : Int { get }
    var baseAddress : PointerType? { get }
    init(start : PointerType?, count : Int)
}

public protocol MutableBufferPointer : BufferPointer where PointerType: MutablePointer {
    static func allocate(capacity : Int) -> Self
}

extension UnsafeMutableRawPointer : MutablePointer {
    
    @_transparent
    @inline(__always)
    public func unsafePointer<T>(with: T.Type) -> UnsafePointer<T> {
        return UnsafePointer<T>(assumingMemoryBound(to: T.self))
    }
    
    @_transparent
    @inline(__always)
    public func unsafeMutablePointer<T>(with: T.Type) -> UnsafeMutablePointer<T> {
        return assumingMemoryBound(to: T.self)
    }

    @_transparent
    @inline(__always)
    public static func allocate(capacity count: Int) -> Me {
        return Me.allocate(byteCount: count, alignment: 1)
    }
}

public extension UnsafeMutableRawPointer {
    
    @_transparent
    @inline(__always)
    func assuming<T>(is: T.Type) -> UnsafeMutablePointer<T> {
        return assumingMemoryBound(to: T.self)
    }
}

extension UnsafeRawPointer : Pointer {}
public extension UnsafeRawPointer {
    
    @_transparent
    @inline(__always)
    func unsafePointer<T>(with: T.Type) -> UnsafePointer<T> {
        return assumingMemoryBound(to: T.self)
    }

    
    @_transparent
    @inline(__always)
    func assuming<T>(is: T.Type) -> UnsafePointer<T> {
        return assumingMemoryBound(to: T.self)
    }
}

extension UnsafeMutablePointer : MutablePointer {}
public extension UnsafeMutablePointer {
    
    @_transparent
    @inline(__always)
    func unsafePointer<T>(with: T.Type) -> UnsafePointer<T> {
        return UnsafePointer<T>(unsafeBitCast(self, to: UnsafeMutablePointer<T>.self))
    }

    @_transparent
    @inline(__always)
    func unsafeMutablePointer<T>(with: T.Type) -> UnsafeMutablePointer<T> {
        return unsafeBitCast(self, to: UnsafeMutablePointer<T>.self)
    }
    
    @_transparent
    @inline(__always)
    func assuming<T>(is: T.Type) -> UnsafeMutablePointer<T> {
        return unsafeBitCast(self, to: UnsafeMutablePointer<T>.self)
    }
}

extension UnsafePointer : Pointer {}
public extension UnsafePointer {
    
    @_transparent
    @inline(__always)
    func unsafePointer<T>(with: T.Type) -> UnsafePointer<T> {
        return unsafeBitCast(self, to: UnsafePointer<T>.self)
    }

    
    @_transparent
    @inline(__always)
    func assuming<T>(is: T.Type) -> UnsafePointer<T> {
        return unsafeBitCast(self, to: UnsafePointer<T>.self)
    }
}

public extension BufferPointer {

    func slice(_ range : Range<Int>) -> Self {
        assert(range.upperBound <= count)
        let size = range.upperBound - range.lowerBound
        let begin = baseAddress?.advanced(by: range.lowerBound)
        return Self(start: begin, count: size)
    }
}

public extension MutableBufferPointer {
    @_transparent
    static func allocate(capacity count : Int) -> Self {
        let mutablePtr = PointerType.allocate(capacity: count)
        return Self(start: mutablePtr, count: count)
    }

}

extension UnsafeMutableBufferPointer : MutableBufferPointer {
    public typealias PointerType = UnsafeMutablePointer<Element>
    
    @_transparent
    public var bufferPointer : UnsafeBufferPointer<Element> {
        return UnsafeBufferPointer(start: baseAddress, count: count)
    }
    
}

extension UnsafeMutableRawBufferPointer : MutableBufferPointer {
    public typealias PointerType = UnsafeMutableRawPointer
    
    @_transparent
    public var bufferPointer : UnsafeRawBufferPointer {
        return UnsafeRawBufferPointer(start: baseAddress, count: count)
    }
}

extension UnsafeRawBufferPointer : BufferPointer {
    public typealias PointerType = UnsafeRawPointer
}

extension UnsafeBufferPointer : BufferPointer {
    public typealias PointerType = UnsafePointer<Element>
    
}
