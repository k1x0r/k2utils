//
// Box.swift
//
// Created by k1x
//

import Foundation

public protocol Boxing {
}

/// Boxing Value Types which need to be accessed by reference
public class Box<T> {
    public var value : T
    public init (_ value : T) {
        self.value = value
    }
}

postfix operator >>
public postfix func >><T>(box : Box<T>) -> T {
    return box.value
}

extension String : Boxing {}
extension NSObject : Boxing {}


public extension Sequence {
    var boxed : Box<Self> {
        return Box(self)
    }
}
public extension Boxing {
    var boxed : Box<Self> {
        return Box(self)
    }
}

public extension Comparable {
    var boxed : Box<Self> {
        return Box(self)
    }
}
