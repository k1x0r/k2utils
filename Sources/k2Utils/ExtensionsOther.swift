//
// ExtensionsOther.swift
//
// Created by k1x
//

import Foundation
import Dispatch

extension Sequence {

    public var array: [Iterator.Element] {
        return Array(self)
    }
}

extension DispatchSemaphore {

    public func wait(timeout: Double) -> DispatchTimeoutResult {
        let time = DispatchTime(secondsFromNow: timeout)
        return wait(timeout: time)
    }
}

extension Double {
    internal var nanoseconds: UInt64 {
        return UInt64(self * Double(1_000_000_000))
    }
}

extension DispatchTime {
    public init(secondsFromNow: Double) {
        let uptime = DispatchTime.now().rawValue + secondsFromNow.nanoseconds
        self.init(uptimeNanoseconds: uptime)
    }
}

extension FixedWidthInteger {

    public var hex: String {
        return String(self, radix: 16).uppercased()
    }
}

extension NSLock {
    public func locked(closure: () throws -> Void) rethrows {
        lock()
        defer { unlock() } // MUST be deferred to ensure lock releases if throws
        try closure()
    }
}

extension Collection {
    /**
     Safely access the contents of a collection. Nil if outside of bounds.
     */
    public subscript(safe idx: Index) -> Iterator.Element? {
        guard startIndex <= idx else { return nil }
        // NOT >=, endIndex is "past the end"
        guard endIndex > idx else { return nil }
        return self[idx]
    }
}



