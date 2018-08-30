//
// IsEmpty.swift
//
// Created by k1x
//

import Foundation

// Empty protocol is a replacement for ?? operator. It provides default value if value is nil and value is empty. It's usable for build in Swift value types like String, Data, Array, etc...

public protocol EmptyProtocol {
    var isEmpty : Bool { get }
}

infix operator ∫

public func ∫ <T: EmptyProtocol>(val1 : T, val2 : T) -> T {
    if !val1.isEmpty {
        return val1
    } else {
        return val2
    }
}

public func ∫ <T: EmptyProtocol>(val1 : T?, val2 : T) -> T {
    if let val = val1, !val.isEmpty {
        return val
    } else {
        return val2
    }
}

extension String : EmptyProtocol {}
extension Data : EmptyProtocol {}
extension Array : EmptyProtocol {}

