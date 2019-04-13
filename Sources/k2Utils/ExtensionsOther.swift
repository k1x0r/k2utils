//
// ExtensionsOther.swift
//
// Created by k1x
//

import Foundation
import Dispatch

public extension Sequence {

    var array: [Iterator.Element] {
        return Array(self)
    }
}

public extension DispatchSemaphore {

    func wait(timeout: Double) -> DispatchTimeoutResult {
        let time = DispatchTime(secondsFromNow: timeout)
        return wait(timeout: time)
    }
}

public extension Double {
    internal var nanoseconds: UInt64 {
        return UInt64(self * Double(1_000_000_000))
    }
}

public extension DispatchTime {
    init(secondsFromNow: Double) {
        let uptime = DispatchTime.now().rawValue + secondsFromNow.nanoseconds
        self.init(uptimeNanoseconds: uptime)
    }
}

public extension FixedWidthInteger {

    var hex: String {
        return String(self, radix: 16, uppercase: true)
    }
    
    var bitHex: String {
        return withUnsafeBytes(of: self) { buff -> String in
            buff.map({ String(format: "%02hhX", $0) }).joined()
        }
    }
}

public extension NSLock {
    func locked(closure: () throws -> Void) rethrows {
        lock()
        defer { unlock() } // MUST be deferred to ensure lock releases if throws
        try closure()
    }
}

public extension Collection {
    /**
     Safely access the contents of a collection. Nil if outside of bounds.
     */
    subscript(safe idx: Index) -> Iterator.Element? {
        guard startIndex <= idx else { return nil }
        // NOT >=, endIndex is "past the end"
        guard endIndex > idx else { return nil }
        return self[idx]
    }
}



