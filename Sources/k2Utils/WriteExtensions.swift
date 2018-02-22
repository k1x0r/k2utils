//
// WriteExtensions.swift
//
// Created by k1x
//

import Foundation

public protocol WriteExtensions {
    @discardableResult
    mutating func write(buffer : UnsafeRawPointer, count : Int) throws -> Int
}

public extension WriteExtensions {
    
    @discardableResult
    mutating func write(string : String) throws -> Int {
        var buf = string.cArray;
        return try write(buffer : &buf, count: buf.count)
    }
    
    @discardableResult
    mutating func write(data : Data) throws -> Int {
        return try data.withUnsafeBytes { (ptr: UnsafePointer<Int8>) -> Int in
            return try write(buffer: ptr, count: data.count)
        }
    }
    
    @discardableResult
    mutating func write(buffer : UnsafeRawBufferPointer) throws -> Int {
        return try write(buffer: buffer.baseAddress!, count: buffer.count)
    }

    @discardableResult
    mutating func write(buffer : UnsafeMutableRawBufferPointer) throws -> Int {
        return try write(buffer: buffer.baseAddress!, count: buffer.count)
    }
    
    @discardableResult
    mutating func write(byteArray : [Int8]) throws -> Int {
        return try write(buffer: byteArray, count: byteArray.count)
    }
 
    @discardableResult
    mutating func write<T>(rawBytes : [T]) throws -> Int {
        return try rawBytes.withUnsafeBytes { bufferPtr -> Int in
            guard let ptr = bufferPtr.baseAddress?.assumingMemoryBound(to: Int8.self) else {
                throw "Something wrong with bytes".error()
            }
            return try write(buffer: ptr, count: bufferPtr.count)
        }
    }
    
    @discardableResult
    mutating func write(stringrn: String) throws  -> Int {
        let sendLine = "\(stringrn)\r\n"
        var cString = sendLine.cArray
        return try write(buffer: &cString, count: cString.count)
    }
    
    @discardableResult
    mutating func writeArray(of stringsrn : [String]) throws -> Int {
        return try write(stringrn: stringsrn.joined(separator: "\r\n"))
    }
    
    @discardableResult
    mutating func write<T>(bytesOf bytes : T) throws -> Int {
        var aCopy = bytes
        var array = toByteArray(&aCopy)
        return try write(buffer: &array, count: array.count)
    }
    
    @discardableResult
    mutating func write<T>(bytesOf bytes: inout T) throws -> Int {
        var array = toByteArray(&bytes)
        return try write(buffer: &array, count: array.count)
    }
    
}
