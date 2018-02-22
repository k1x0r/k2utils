//
// ThreadExtensions.swift
//
// Created by k1x
//

import Foundation

public class BlockThread : Thread {
    
    internal var block : ()->()
    
    public init(closure : @escaping ()->()) {
        self.block = closure
    }
    
    override public func main() {
        block()
    }
    
}
