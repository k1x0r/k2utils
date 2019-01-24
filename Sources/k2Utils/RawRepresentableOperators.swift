//
// RawRepresentableOperators.swift
//
// Created by k1x
//

import Foundation

postfix operator ~;
postfix operator ~~;
prefix operator ~;

prefix public func ~<T : RawRepresentable>(rr : T) -> T.RawValue {
    return rr.rawValue;
}

prefix public func ~<T : RawRepresentable>(rr : T) -> T.RawValue? {
    return rr.rawValue;
}

prefix public func ~<T : RawRepresentable>(rr : T?) -> T.RawValue? {
    guard let r = rr else {
        return nil;
    }
    return r.rawValue;
}

postfix public func ~~<T : RawRepresentable>(rr : T.RawValue) -> T {
    return T(rawValue : rr)!;
}

postfix public func ~<T : RawRepresentable>(rr : T.RawValue?) -> T? {
    guard let r = rr else {
        return nil;
    }
    return T(rawValue : r);
}

@inline(__always)
public func toByteArray<T>(_ value: T) -> [Int8] {
    var value = value
    return withUnsafeBytes(of: &value) { unsafeBitCast(Array($0), to: [Int8].self)  }
}

@inline(__always)
public func toByteArray<T>( _ value: inout T) -> [Int8] {
    return withUnsafeBytes(of: &value) { unsafeBitCast(Array($0), to: [Int8].self)  }
}

@inline(__always)
public func toUInt8Array<T>( _ value: inout T) -> [UInt8] {
    return withUnsafeBytes(of: &value) { Array($0) }
}


@inline(__always)
public func fromByteArray<T>(_ value: [Int8], _: T.Type) -> T {
    return value.withUnsafeBytes {
        $0.baseAddress!.load(as: T.self)
    }
}
