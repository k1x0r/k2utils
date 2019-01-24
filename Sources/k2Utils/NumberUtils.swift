//
// NumberUtils.swift
//
// Created by k1x
//

import Foundation

public extension BinaryInteger {
    
    func plusMinus<T : BinaryInteger>(_ bound : T) -> T {
        return T.init(clamping: self) % (bound * 2) - bound
    }
    
    func within<T : BinaryInteger>(_ range : Range<T>) -> T {
        let span = range.upperBound - range.lowerBound
        return range.lowerBound + T.init(clamping: self) % span
    }
}
