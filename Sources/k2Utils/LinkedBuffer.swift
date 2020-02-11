//
// LinkedBuffer.swift
//
// Created by k1x
//

import Foundation

public class LinkedBuffer : WriteExtensions, Reader {
    
    typealias SubbuffersList = LinkedList<LinkedBufferNode>
    
    public struct LinkedBufferNode {
        public var data : [Int8]
        public var read : Int = 0
        public var written : Int = 0
        
        init(capacity : Int) {
            data = [Int8](repeating: 0, count: capacity)
        }
        
        var leftBytes : Int {
            return data.count - written
        }
        
        var readLeft : Int {
            return written - read
        }
    }
    
    var subBuffers = SubbuffersList()
    var bufferSize : Int
    
    public init(bufferSize : Int) {
        self.bufferSize = bufferSize
        subBuffers.push(LinkedBufferNode(capacity: bufferSize))
    }
    
    public func pop() -> LinkedBufferNode? {
        return subBuffers.popFirst()
    }
    
    public var headSubbuffer : LinkedList<LinkedBufferNode>.Node? {
        return subBuffers.firstNode
    }
    
    public func removeSubbufer(subbufer: LinkedList<LinkedBufferNode>.Node) {
        subBuffers.remove(node: subbufer)
    }
    
    public func read(buffer: UnsafeMutableRawPointer, count: Int) throws -> SocketReadResult {
        var node = subBuffers.firstNode
        var position = 0
        @_transparent func bytesLeft() -> Int {
            return count - position
        }
        while let unode = node, bytesLeft() > 0 {
            let bytesToRead = min(bytesLeft(), unode.value.readLeft)
            let alreadyRead = unode.value.read
            unode.value.data.withUnsafeBytes { src -> Void in
                memcpy(buffer.advanced(by: position), src.baseAddress!.advanced(by: alreadyRead), bytesToRead)
            }
            position += bytesToRead
            unode.value.read += bytesToRead
            if unode.value.readLeft <= 0 {
                node = unode.next
                subBuffers.remove(node: unode)
            }
        }
        return SocketReadResult(position, options: subBuffers.firstNode != nil ? [] : .endOfStream)
    }
    
    public func write(buffer: UnsafeRawPointer, count: Int) throws -> Int {
        guard var node = subBuffers.lastNode else {
            throw "Unknown error. No node.".error()
        }
        var position = 0
        @_transparent func bytesLeft() -> Int {
            return count - position
        }
        while bytesLeft() > 0 {
            guard node.value.leftBytes > 0 else {
                let newNode = SubbuffersList.Node(value: LinkedBufferNode(capacity: bufferSize))
                subBuffers.push(newNode)
                node = newNode
                continue
            }
            let bytesToWrite = min(bytesLeft(), node.value.leftBytes)
            let written = node.value.written
            node.value.data.withUnsafeMutableBytes { dst -> Void in
                memcpy(dst.baseAddress!.advanced(by: written), buffer.advanced(by: position), bytesToWrite)
            }
            position += bytesToWrite
            node.value.written += bytesToWrite
        }
        return count
    }
    
    
}
